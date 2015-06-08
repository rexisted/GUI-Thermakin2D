function varargout = Layers_1D(varargin)
% LAYERS_1D MATLAB code for Layers_1D.fig
%      LAYERS_1D, by itself, creates a new LAYERS_1D or raises the existing
%      singleton*.
%
%      H = LAYERS_1D returns the handle to a new LAYERS_1D or the handle to
%      the existing singleton*.
%
%      LAYERS_1D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAYERS_1D.M with the given input arguments.
%
%      LAYERS_1D('Property','Value',...) creates a new LAYERS_1D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Layers_1D_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Layers_1D_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Layers_1D

% Last Modified by GUIDE v2.5 12-Feb-2015 00:33:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Layers_1D_OpeningFcn, ...
                   'gui_OutputFcn',  @Layers_1D_OutputFcn, ...
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


% --- Executes just before Layers_1D is made visible.
function Layers_1D_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Layers_1D (see VARARGIN)

% Choose default command line output for Layers_1D
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Layers_1D wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Layers_1D_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



function add_layer_Callback(hObject, eventdata, handles)

function remove_layer_Callback(hObject, eventdata, handles)


function mass_frac1_Callback(hObject, eventdata, handles)
function mass_frac1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function mass_frac2_Callback(hObject, eventdata, handles)
function mass_frac2_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Thick_Callback(hObject, eventdata, handles)
function Thick_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Temp_Callback(hObject, eventdata, handles)
function Temp_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function layer_create_Callback(hObject, eventdata, handles)

function slider1_Callback(hObject, eventdata, handles)
function slider1_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
