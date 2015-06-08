function varargout = untitled(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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

% --- Executes just before untitled is made visible.
function untitled_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = untitled_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
items = get(hObject,'String');
index_selected = get(hObject,'Value');
Materials = {'KAOWOOL';'AL';'PMMA';'PMMA_glass';'PMMA_ch';'PMMA_g'};%Array of Data {Need to be info about fruit or cmp}
MATRESULTS = (Materials(index_selected)); %Selected info we want to show
display(MATRESULTS); 
dlmwrite('results.txt',MATRESULTS,',')


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hOblect,'String',{'KAOWOOL';'AL';'PMMA';'PMMA_glass';'PMMA_ch';'PMMA_g';});

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)