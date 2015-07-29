function varargout = untitled2(varargin)
% UNTITLED2 MATLAB code for untitled2.fig
%      UNTITLED2, by itself, creates a new UNTITLED2 or raises the existing
%      singleton*.
%
%      H = UNTITLED2 returns the handle to a new UNTITLED2 or the handle to
%      the existing singleton*.
%
%      UNTITLED2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNTITLED2.M with the given input arguments.
%
%      UNTITLED2('Property','Value',...) creates a new UNTITLED2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before untitled2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to untitled2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help untitled2

% Last Modified by GUIDE v2.5 22-Sep-2014 16:58:05

% Begin initialization code - DO NOT EDIT
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
% End initialization code - DO NOT EDIT


% --- Executes just before untitled2 is made visible.
function untitled2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to untitled2 (see VARARGIN)

% Choose default command line output for untitled2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes untitled2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = untitled2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in cmp_popupmenu.
function cmp_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to cmp_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure wih handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cmp_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cmp_popupmenu


% items = get(hObject,'String'); %
index_selected = get(hObject,'Value');
% PMMA = [1150 0 0 0; 601.4 3.63 0 0; 0.45 -3.8e-4 0 0; 2e-5 0 0 0];
% KAOWOOL = [240 0 0 0; 1070 0 0 0; 0.0519 -4e-5 1e-7 2; 1e-30 0 0 0];
% AL = [2700 0 0 0; 910 0 0 0; 237 0 0 0; 1e-30 0 0 0];
% PMMA_glass = [1150 0 0 0; 601.4 3.63 0 0; 0.27 -2.4e-4 0 0; 2e-5 0 0 0];
% PMMA_ch = [1180 0 0 0; 1000 0 0 0; 0.25 0 0 0; 2e-5 0 0 0];
% PMMA_g = [1 0 0 0; 1880 0 0 0; 8.876e-4 -1.16e-5 1.55e-7 2; 2e-5 0 0 0];

%items = get(Apple,'String');
%index_selected = get(Apple,'Value');
%item_selected = items{index_selected};
Materials = {[240  0  0  0; 1070  0 0 0; 0.0519 -4e-5 1e-7 2; 1e-30 0 0 0];[2700 0 0 0; 910 0 0 0; 237 0 0 0; 1e-30 0 0 0];[1150 0 0 0; 601.4 3.63 0 0; 0.45 -3.8e-4 0 0; 2e-5 0 0 0];[1150 0 0 0; 601.4 3.63 0 0; 0.27 -2.4e-4 0 0; 2e-5 0 0 0];[1180 0 0 0; 1000 0 0 0; 0.25 0 0 0; 2e-5 0 0 0];[1 0 0 0; 1880 0 0 0; 8.876e-4 -1.16e-5 1.55e-7 2; 2e-5 0 0 0];};%Array of Data {Need to be info about fruit or cmp}
RMAT = (Materials(index_selected)); %Selected info we want to show
dlmwrite('Results.cmp',RMAT,','); %Write a txt file with selected info form CAKE



% --- Executes during object creation, after setting all properties.
function cmp_popupmenu_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'KAOWOOL';'AL';'PMMA';'PMMA_glass';'PMMA_ch';'PMMA_g'});


% --- Executes on button press in output_file.
function output_file_Callback(hObject, eventdata, handles)
% hObject    handle to output_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




