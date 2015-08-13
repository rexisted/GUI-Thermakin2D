    clc
    clear
F = dir('*.cmp');
for ii = 1:length(F)
    [pathstr,name,ext]=fileparts(F(ii).name);
    fname{ii}=name;
    fdd = fopen(F(ii).name);
    file_strings{ii} = textscan(fdd,'%s','Delimiter','');
%     file_strings2{ii} = textscan(fdd,'%s','Delimiter', ':');
end

file_strings_sz = size(file_strings{1}); %size of file_strings (number of rows)
    ix = 0; %counter for amount of components
    for  file_strings_ix=1:file_strings_sz(1,1)%while the counter is less than the actual amount of lines in file continue loop
        ix = ix+1;
        list{ix,1} = cellstr(file_strings{1}{file_strings_ix});
        ex = strcmp((file_strings{1}{file_strings_ix}),'MIXTURES');
        if ex=='1'
            disp('WORKED');
            break;
        else
            disp('WTF');
        end
    end
