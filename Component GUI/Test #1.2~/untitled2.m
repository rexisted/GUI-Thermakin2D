function varargout = untitled2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled2_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled2_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes just before untitled2 is made visible.
function untitled2_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = untitled2_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in cmp_popupmenu.
function cmp_popupmenu_Callback(hObject, eventdata, handles)
% items = get(hObject,'String'); %
index_selected = get(hObject,'Value');
% PMMA = [1150 0 0 0; 601.4 3.63 0 0; 0.45 -3.8e-4 0 0; 2e-5 0 0 0];
% KAOWOOL = [240 0 0 0; 1070 0 0 0; 0.0519 -4e-5 1e-7 2; 1e-30 0 0 0];
% AL = [2700 0 0 0; 910 0 0 0; 237 0 0 0; 1e-30 0 0 0];
% PMMA_glass = [1150 0 0 0; 601.4 3.63 0 0; 0.27 -2.4e-4 0 0; 2e-5 0 0 0];
% PMMA_ch = [1180 0 0 0; 1000 0 0 0; 0.25 0 0 0; 2e-5 0 0 0];
% PMMA_g = [1 0 0 0; 1880 0 0 0; 8.876e-4 -1.16e-5 1.55e-7 2; 2e-5 0 0 0];

Materials = {[240  0  0  0; 1070  0 0 0; 0.0519 -4e-5 1e-7 2; 1e-30 0 0 0];
    [2700 0 0 0; 910 0 0 0; 237 0 0 0; 1e-30 0 0 0];
    [1150 0 0 0; 601.4 3.63 0 0; 0.45 -3.8e-4 0 0; 2e-5 0 0 0];
    [1150 0 0 0; 601.4 3.63 0 0; 0.27 -2.4e-4 0 0; 2e-5 0 0 0];
    [1180 0 0 0; 1000 0 0 0; 0.25 0 0 0; 2e-5 0 0 0];
   [1 0 0 0; 1880 0 0 0; 8.876e-4 -1.16e-5 1.55e-7 2; 2e-5 0 0 0];};%Array of Data {Need to be info about fruit or cmp}
RMAT = (Materials(index_selected)); %Selected info we want to show
dlmwrite('Results.cmp',RMAT,',') %Write a txt file with selected info form CAKE


% --- Executes during object creation, after setting all properties.
function cmp_popupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'KAOWOOL';'AL';'PMMA';'PMMA_glass';'PMMA_ch';'PMMA_g'});


% --- Executes on button press in output_file.
function output_file_Callback(hObject, eventdata, handles)

function edit1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Move_cmp_left.
function Move_cmp_left_Callback(hObject, eventdata, handles)

function Move_cmp_right_Callback(hObject, eventdata, handles)

% --- Executes on selection change in CMPlist_1.
function CMPlist_1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CMPlist_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CMPlist_2.
function CMPlist_2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function CMPlist_2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Move_cmp_left_CreateFcn(hObject, eventdata, handles)
