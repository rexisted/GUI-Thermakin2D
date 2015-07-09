function varargout = Cond_2D(varargin)
% COND_2D MATLAB code for Cond_2D.fig
%      COND_2D, by itself, creates a new COND_2D or raises the existing
%      singleton*.
%
%      H = COND_2D returns the handle to a new COND_2D or the handle to
%      the existing singleton*.
%
%      COND_2D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COND_2D.M with the given input arguments.
%
%      COND_2D('Property','Value',...) creates a new COND_2D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cond_2D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cond_2D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cond_2D

% Last Modified by GUIDE v2.5 13-Dec-2014 23:17:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cond_2D_OpeningFcn, ...
                   'gui_OutputFcn',  @Cond_2D_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before Cond_2D is made visible.
function Cond_2D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cond_2D (see VARARGIN)

% Choose default command line output for Cond_2D
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cond_2D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Cond_2D_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in create_cnd.
function create_cnd_Callback(hObject, eventdata, handles)
%% INTEGRATION PARAMETERS

ele_s = get(handles.elem_size,'String');
time1 =  get(handles.time_1,'String');
durn = get(handles.dur,'String');
elem = get(handles.elems,'String');
time2 = get(handles.time_2,'String');
layer_s = '0.0025'; %get(handles._____,'String'); fix this
layer = '1'; %get(handles._____,'String'); fix this

INT_PARA{1,1} = 'INTEGRATION PARAMETERS';
INT_PARA{2,1} = '**********************';
INT_PARA{3,1} = ' ';
INT_PARA{4,1} = sprintf('LAYER SIZE:  %s',layer_s);%0.0025';
INT_PARA{5,1} = sprintf('ELEMENT SIZE:  %s',ele_s);%5e-5';
INT_PARA{6,1} = sprintf('TIME STEP:  %s',time1);%0.01';
INT_PARA{7,1} = sprintf('DURATION:  %s',durn);%600';
INT_PARA{7,1} = '  ';
INT_PARA{8,1} = 'OUTPUT FREQUENCY:';
INT_PARA{9,1} = sprintf('LAYERS:  %s',layer);%1';
INT_PARA{10,1} = sprintf('ELEMENTS:  %s',elem);%20';
INT_PARA{11,1} = sprintf('TIME STEPS:  %s',time2);%100';
%%

%%
I = char(INT_PARA);
disp(I);

function dim_change_Callback(hObject, eventdata, handles)
items = get(hObject,'String');
index_selected = get(hObject,'Value');
item_selected = items{index_selected};
if index_selected == 2;
    set(handles.figure1,'Visible','On');
    set(handles.figure;
    %make value from other .m file to be avaliable here
end

function dim_change_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'2D','1D'});


function elem_size_Callback(hObject, eventdata, handles)
get(hObject,'String');

function elem_size_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function time_1_Callback(hObject, eventdata, handles)
get(hObject,'String');

function time_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function dur_Callback(hObject, eventdata, handles)
get(hObject,'String');

function dur_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function elems_Callback(hObject, eventdata, handles)
get(hObject,'String');

function elems_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function time_2_Callback(hObject, eventdata, handles)
get(hObject,'String');

function time_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
