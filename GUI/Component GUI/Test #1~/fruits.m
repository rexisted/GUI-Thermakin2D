function varargout = fruits(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fruits_OpeningFcn, ...
                   'gui_OutputFcn',  @fruits_OutputFcn, ...
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

function fruits_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = fruits_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on selection change in fruits.
function fruits_Callback(Apple, eventdata, handles)
items = get(Apple,'String');
index_selected = get(Apple,'Value');
item_selected = items{index_selected};
display(item_selected);

% --- Executes during object creation, after setting all properties.
function fruits_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Apple';'Pear';'Oranges';'Grapes';'Banana'});
set(handles.fruits,'Value',1)
set(handles.fruits,'Value',2)
set(handles.fruits,'Value',3)
set(handles.fruits,'Value',4)
set(handles.fruits,'Value',5)


% --- Executes on button press in Process.
function Process_Callback(hObject, eventdata, handles)
display('Goodbye');
close(gcf);