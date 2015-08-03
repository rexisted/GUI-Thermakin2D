function varargout = ThermaGUI(varargin)
% THERMAGUI MATLAB code for ThermaGUI.figMAGUI or raises the existing
%      singleton*.
%      THERMAGUI, by itself, creates a new THER
%
%      H = THERMAGUI returns the handle to a new THERMAGUI or the handle to
%      the existing singleton*.
%
%      THERMAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THERMAGUI.M with the given input arguments.
%
%      THERMAGUI('Property','Value',...) creates a new THERMAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ThermaGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ThermaGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ThermaGUI

% Last Modified by GUIDE v2.5 28-Jul-2015 18:34:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ThermaGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ThermaGUI_OutputFcn, ...
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

% --- Executes just before ThermaGUI is made visible.
function ThermaGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ThermaGUI (see VARARGIN)

% Choose default command line output for ThermaGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global cond_fig_limit comp_fig_limit
cond_fig_limit = 0;
comp_fig_limit = 0;

% UIWAIT makes ThermaGUI wait for user response (see UIRESUME)
% uiwait(handles.Intropage);

% --- Outputs from this function are returned to the command line.
function varargout = ThermaGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function cond_button_Callback(hObject, eventdata, handles)
global cond_fig_limit %Introduces limit which limits window to open once
if cond_fig_limit == 0 %If its not opened
cond_figure = figure('Position',[200,200,900,575],'Resize','Off',... %Creates Conditions figure sets it to cond_figure
    'MenuBar','none','Name','Conditions','tag','cond_fig',...
    'CloseRequestFcn',@closereq);
cond_fig_limit = 1; %sets limit to 1 which stops creation of figure
elseif cond_fig_limit == 1 %If it is opened
cond_figure = findobj('Tag','cond_fig'); %set figure 'cond_fig' to cond_figure
cond_figure.Visible = 'On'; %makes figure visible
drawnow;
end


function comp_button_Callback(hObject, eventdata, handles)
global comp_fig_limit %Introduces limit which limits window to open once
if comp_fig_limit == 0 %If its not opened
comp_figure = figure('Position',[520,460,440,300],'Resize','Off',... %Creates Components figure sets it to cond_figure
    'MenuBar','none','Name','Components','tag','comp_fig',...
    'CloseRequestFcn',@closereq);
comp_fig_limit = 1; %sets limit to 1 which stops creation of figure
elseif comp_fig_limit == 1 %If it is opened
    comp_figure = findobj('Tag','comp_fig'); %set figure 'comp_fig' to comp_figure
    comp_figure.Visible = 'On'; %makes figure visible
    drawnow;
end


function out_button_Callback(hObject, eventdata, handles)
global out_fig_limit %Introduces limit which limits window to open once
if out_fig_limit == 0 %If its not opened
out_figure = figure('Position',[520,460,440,300],'Resize','Off',... %Creates Output figure sets it to cond_figure
    'MenuBar','none','Name','Output','tag','out_fig',...
    'CloseRequestFcn',@closereq);
out_fig_limit = 1; %sets limit to 1 which stops creation of figure
elseif out_fig_limit == 1 %If it is opened
    out_figure = findobj('Tag','comp_fig'); %set figure 'out_fig' to out_figure
    out_figure.Visible = 'On'; %makes figure visible
    drawnow;
end


function tk2d_button_Callback(hObject, eventdata, handles)

function closereq(src,callbackdata)
global cond_fig_limit comp_fig_limit
% Close request function 
% to display a question dialog box 
   selection = questdlg('Close This Figure?',...
      'Close Request Function',...
      'Yes','No','Yes'); 
   switch selection, 
      case 'Yes',
          disp(gcf)
         delete(gcf)
         comp_fig_limit = 0;
      case 'No'
      return 
   end

