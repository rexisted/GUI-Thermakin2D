search_cmp = dir('COMPONENTS.cmp');
for ii = 1:length(search_cmp)
   [pathstr,name,ext]=fileparts(search_cmp(ii).name);
   cmp_name{ii}=name;
   fdd = fopen(search_cmp(ii).name);
%    cmp_list{ii} = textscan(fdd,'%s','Delimiter',':');
   cmp_list_orig{ii} = textscan(fdd,'%s','Delimiter','');
end

