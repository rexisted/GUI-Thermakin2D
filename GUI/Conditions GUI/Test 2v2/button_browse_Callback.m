function button_browse_Callback(hObject, eventdata, handles)
global baseFileName folder;
[baseFileName, folder] = uigetfile();
function button_load_Callback(hObject, eventdata, handles)
global baseFileName folder;
fullFileName = fullfile(folder, baseFileName);
fid=fopen(fullFileName ,'rt');