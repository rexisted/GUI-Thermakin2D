clc
clear
cmp_file = dir('COMPONENTS.cmp');
cmp_a = textscan(fopen(cmp_file.name),'%s','Delimiter',':');


cmp_a_sz = size(cmp_a{1});

cmpname_cnt = 0;
for  cmp_a_cnt=1:cmp_a_sz(1,1)
    if strcmp(cmp_a{1}{cmp_a_cnt},'MATERIAL')
        cmpname_cnt=cmpname_cnt+1;
        cmpname(cmpname_cnt) = cellstr(cmp_a{1}{cmp_a_cnt+1});
    end
end

cmp_b = textscan(fopen(cmp_file.name),'%s','Delimiter','');
cmp_b_sz = size(cmp_b{1});
cmp_b_cnt = 0;
cmpname_cnt = 0;

while cmp_b_cnt < cmp_b_sz(1,1)
    cmp_b_cnt = cmp_b_cnt+1;
    if strncmp((cmp_b{1}{cmp_b_cnt}),'MATERIAL',8);
        cmp_c_cnt = 1;
        cmpname_cnt = cmpname_cnt+1;
        while cmp_b_cnt < cmp_b_sz(1,1) && ~strncmp(cmp_b{1}{cmp_b_cnt+1},'MATERIAL',8)
            cmp_b_cnt = cmp_b_cnt+1;
            cmp_c{cmpname_cnt}{cmp_c_cnt}= cellstr(cmp_b{1}{cmp_b_cnt});
            cmp_c_cnt= cmp_c_cnt+1;
        end
        cmp_c{cmpname_cnt} = transpose(cmp_c{1,cmpname_cnt});
    end
end


for cmpname_cnt=1:cmpname_cnt
    cmp_cnt = 1;
    cmp_e_cnt = 0;
    cmp_d_cnt = 0;
    cmp_c_sz = size(cmp_c{cmpname_cnt});
    
    while cmp_cnt < cmp_c_sz(1,1) && ~strncmp(cmp_c{cmpname_cnt}{cmp_cnt},'REACTION',8)
        cmp_d_cnt = cmp_d_cnt + 1;
        cmp_d{cmpname_cnt}{cmp_d_cnt}= cellstr(cmp_c{cmpname_cnt}{cmp_cnt});
        cmp_cnt = cmp_cnt + 1;
    end
    cmp_d{cmpname_cnt} = transpose(cmp_d{1,cmpname_cnt});
    
    for i=1:cmp_d_cnt
        cmp_d_char{i,:,cmpname_cnt}= char(cmp_d{1,cmpname_cnt}{i,1});
    end
    cmp_d_char{cmpname_cnt} = char(cmp_d_char{:,1,cmpname_cnt});
    
    while cmp_cnt <= cmp_c_sz(1,1)
        cmp_e_cnt = cmp_e_cnt + 1;
        cmp_e{cmpname_cnt}{cmp_e_cnt}= cellstr(cmp_c{cmpname_cnt}{cmp_cnt});
        cmp_cnt = cmp_cnt + 1;
    end
    cmp_e{cmpname_cnt} = transpose(cmp_e{1,cmpname_cnt});
    
    for i=1:cmp_e_cnt
        cmp_e_char{i,:,cmpname_cnt}= char(cmp_e{1,cmpname_cnt}{i,1});
    end
    cmp_e_char{cmpname_cnt} = char(cmp_e_char{:,1,cmpname_cnt});
end

comp_selected = [2,4,5,8];
cmp_e_char = char(cmp_e_char{comp_selected});
cmp_d_char = char(cmp_d_char{comp_selected});

cmp_d_char(all(cmp_d_char == ' ', 2), :) = [];
cmp_e_char(all(cmp_e_char == ' ', 2), :) = [];


[FileName,PathName] = uiputfile('*.exp','Save as');
if isequal(FileName,0) %if no file is chosen or canceled then display Cancel
    disp('User selected Cancel')
else
    dlmwrite(FileName,cmp_d_char,'delimiter', '', 'newline', 'pc');
    disp(pwd);
    disp(PathName);
    dir_sz = size(PathName,2);
    if ~strncmp(pwd,PathName,dir_sz-1)
        movefile(FileName,PathName,'f');
    end
end

