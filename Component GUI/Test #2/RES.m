function varargout = RES(varargin)
% RES MATLAB code for RES.fig
%      RES, by itself, creates a new RES or raises the existing
%      singleton*.
%
%      H = RES returns the handle to a new RES or the handle to
%      the existing singleton*.
%
%      RES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RES.M with the given input arguments.
%
%      RES('Property','Value',...) creates a new RES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RES_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RES_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RES

% Last Modified by GUIDE v2.5 28-Sep-2014 16:17:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RES_OpeningFcn, ...
                   'gui_OutputFcn',  @RES_OutputFcn, ...
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

% --- Executes just before RES is made visible.
function RES_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RES (see VARARGIN)

% Choose default command line output for RES
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = RES_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
%% KAOWOOL
MATERIALS{1,1,1} = 'COMPONENT:       KAOWOOL';
MATERIALS{2,1,1} = 'STATE:           S';
MATERIALS{3,1,1} = 'DENSITY:         240  0  0  0';
MATERIALS{4,1,1} = 'HEAT CAPACITY:   1070  0  0  0';
MATERIALS{5,1,1} = 'CONDUCTIVITY:    0.0519  -4e-5  1e-7  2';
MATERIALS{6,1,1} = 'TRANSPORT:       1e-30  0  0  0';
MATERIALS{7,1,1} = 'EMISSIVITY & ABSORPTION:  0  10000';
MATERIALS{8,1,1} = ' ';
%%
%% ALUMINIUM
MATERIALS{1,1,2} = 'COMPONENT:       AL';
MATERIALS{2,1,2} = 'STATE:           S';
MATERIALS{3,1,2} = 'DENSITY:         2700  0  0  0';
MATERIALS{4,1,2} = 'HEAT CAPACITY:   910  0  0  0';
MATERIALS{5,1,2} = 'CONDUCTIVITY:    237  0  0  0';
MATERIALS{6,1,2} = 'TRANSPORT:       1e-30  0  0  0';
MATERIALS{7,1,2} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{8,1,2} = ' ';
%% 
%% PMMA
MATERIALS{1,1,3} = 'COMPONENT:       PMMA';
MATERIALS{2,1,3} = 'STATE:           S';
MATERIALS{3,1,3} = 'DENSITY:         1150  0  0  0';
MATERIALS{4,1,3} = 'HEAT CAPACITY:   601.4  3.63  0  0';
MATERIALS{5,1,3} = 'CONDUCTIVITY:    0.45 -3.8e-4  0  0';
MATERIALS{6,1,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,3} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{8,1,3} = ' ';

MATERIALS{1,2,3} = 'COMPONENT:       PMMA_glass';
MATERIALS{2,2,3} = 'STATE:           S';
MATERIALS{3,2,3} = 'DENSITY:         1150  0  0  0';
MATERIALS{4,2,3} = 'HEAT CAPACITY:   601.4  3.63  0  0';
MATERIALS{5,2,3} = 'CONDUCTIVITY:    0.27 -2.4e-4  0  0';
MATERIALS{6,2,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,3} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{8,2,3} = ' ';

MATERIALS{1,3,3} = 'COMPONENT:       PMMA_ch';
MATERIALS{2,3,3} = 'STATE:           S';
MATERIALS{3,3,3} = 'DENSITY:         1180  0  0  0';
MATERIALS{4,3,3} = 'HEAT CAPACITY:   1000  0  0  0';
MATERIALS{5,3,3} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{6,3,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,3} = 'EMISSIVITY & ABSORPTION:  0  10000';
MATERIALS{8,3,3} = ' ';

MATERIALS{1,4,3} = 'COMPONENT:       PMMA_g';
MATERIALS{2,4,3} = 'STATE:           G';
MATERIALS{3,4,3} = 'DENSITY:         1  0  0  0';
MATERIALS{4,4,3} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{5,4,3} = 'CONDUCTIVITY:    8.876e-4  -1.16e-5  1.55e-7  2';
MATERIALS{6,4,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,3} = 'EMISSIVITY & ABSORPTION:  1  10000';
MATERIALS{8,4,3} = ' ';

MATERIALS{1,6,3} = 'REACTION:       PMMA + NOCOMP -> PMMA_glass + NOCOMP';
MATERIALS{2,6,3} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,6,3} = 'ARRHENIUS:      1  0';
MATERIALS{4,6,3} = 'HEAT:           0  0  0  0';
MATERIALS{5,6,3} = 'TEMP LIMIT:     L  378';
MATERIALS{5,6,3} = ' ';

MATERIALS{1,7,3} = 'REACTION:       PMMA_glass + NOCOMP -> PMMA_ch + PMMA_g';
MATERIALS{2,7,3} = 'STOICHIOMETRY:  1    0         0    1';
MATERIALS{3,7,3} = 'ARRHENIUS:      8.6e12  188100';
MATERIALS{4,7,3} = 'HEAT:           -846000  0  0  0';
MATERIALS{5,7,3} = 'TEMP LIMIT:     L  300';
%% 
%% HIPS
MATERIALS{1,1,4} = 'COMPONENT:       HIPS';
MATERIALS{2,1,4} = 'STATE:           S';
MATERIALS{3,1,4} = 'DENSITY:         1060  0  0  0';
MATERIALS{4,1,4} = 'HEAT CAPACITY:   591.58  3.421  0  0';
MATERIALS{5,1,4} = 'CONDUCTIVITY:    0.12  0.000113  0  0';
MATERIALS{6,1,4} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,4} = 'EMISSIVITY & ABSORPTION:  0.95  2.12';
MATERIALS{8,1,4} = ' ';

MATERIALS{1,2,4} = 'COMPONENT:       HIPS_ch';
MATERIALS{2,2,4} = 'STATE:           S';
MATERIALS{3,2,4} = 'DENSITY:         265  0  0  0';
MATERIALS{4,2,4} = 'HEAT CAPACITY:   1250  0  0  0';
MATERIALS{5,2,4} = 'CONDUCTIVITY:    0.5  0  0  0';
MATERIALS{6,2,4} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,4} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{8,2,4} = ' ';

MATERIALS{1,3,4} = 'COMPONENT:       HIPS_g';
MATERIALS{2,3,4} = 'STATE:           G';
MATERIALS{3,3,4} = 'DENSITY:         1060  0  0  0';
MATERIALS{4,3,4} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{5,3,4} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{6,3,4} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,4} = 'EMISSIVITY & ABSORPTION:  1  2.12';
MATERIALS{8,3,4} = ' ';

MATERIALS{1,4,4} = 'REACTION:       HIPS + NOCOMP -> HIPS_ch + HIPS_g';
MATERIALS{2,4,4} = 'STOICHIOMETRY:  1    0         0.043    0.957';
MATERIALS{3,4,4} = 'ARRHENIUS:      1.705e20  300500';
MATERIALS{4,4,4} = 'HEAT:           -689000  0  0  0';
MATERIALS{5,4,4} = 'TEMP LIMIT:     L  300';
%% 
%% Kydex
MATERIALS{1,1,5} = 'COMPONENT:       Kydex';	
MATERIALS{2,1,5} = 'STATE:           S';
MATERIALS{3,1,5} = 'DENSITY:         1350  0  0  0';
MATERIALS{4,1,5} = 'HEAT CAPACITY:   -624.26  5.93333  0  0';
MATERIALS{5,1,5} = 'CONDUCTIVITY:    0.28  -0.00029 0  0';
MATERIALS{6,1,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,5} = 'EMISSIVITY & ABSORPTION:  0.95  1.58';
MATERIALS{8,1,5} = ' ';

MATERIALS{1,2,5} = 'COMPONENT:       Kydex_1';
MATERIALS{2,2,5} = 'STATE:           S';
MATERIALS{3,2,5} = 'DENSITY:         100  0  0  0';
MATERIALS{4,2,5} = 'HEAT CAPACITY:   265  3.01  0  0';
MATERIALS{5,2,5} = 'CONDUCTIVITY:    0.55  0.00003  0  0';
MATERIALS{6,2,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,5} = 'EMISSIVITY & ABSORPTION:  0.95  30';
MATERIALS{8,2,5} = ' ';

MATERIALS{1,3,5} = 'COMPONENT:       Kydex_ch';
MATERIALS{2,3,5} = 'STATE:           S';
MATERIALS{3,3,5} = 'DENSITY:         100  0  0  0';
MATERIALS{4,3,5} = 'HEAT CAPACITY:   1150  0.0956  0  0';
MATERIALS{5,3,5} = 'CONDUCTIVITY:    0.28  8.4e-5  3.0e-10  3';
MATERIALS{6,3,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,5} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{8,3,5} = ' ';

MATERIALS{1,4,5} = 'COMPONENT:       Kydex_g1';
MATERIALS{2,4,5} = 'STATE:           G';
MATERIALS{3,4,5} = 'DENSITY:         1350  0  0  0';
MATERIALS{4,4,5} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,4,5} = 'CONDUCTIVITY:    0.28  -0.00028 0  0';
MATERIALS{6,4,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,5} = 'EMISSIVITY & ABSORPTION:  0.95  1.58';
MATERIALS{8,4,5} = ' ';

MATERIALS{1,5,5} = 'COMPONENT:       Kydex_g2';
MATERIALS{2,5,5} = 'STATE:           G';
MATERIALS{3,5,5} = 'DENSITY:         1350  0  0  0';
MATERIALS{4,5,5} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,5,5} = 'CONDUCTIVITY:    0.28  -0.00028 0  0';
MATERIALS{6,5,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,5,5} = 'EMISSIVITY & ABSORPTION:  0.95  1.58';
MATERIALS{8,5,5} = ' ';

MATERIALS{1,6,5} = 'REACTION:       Kydex + NOCOMP -> Kydex_1 + Kydex_g1';
MATERIALS{2,6,5} = 'STOICHIOMETRY:  1    0         0.45    0.55';
MATERIALS{3,6,5} = 'ARRHENIUS:      6.025e10  141000';
MATERIALS{4,6,5} = 'HEAT:           -180000  0  0  0';
MATERIALS{5,6,5} = 'TEMP LIMIT:     L  300';
MATERIALS{6,6,5} = ' ';

MATERIALS{1,7,5} = 'REACTION:       Kydex_1 + NOCOMP -> Kydex_ch + Kydex_g2';
MATERIALS{2,7,5} = 'STOICHIOMETRY:  1    0         0.31    0.69';
MATERIALS{3,7,5} = 'ARRHENIUS:      1.355e10  174000';
MATERIALS{4,7,5} = 'HEAT:           -124400  0  0  0';
MATERIALS{5,7,5} = 'TEMP LIMIT:     L  300';
%%
%% CB
MATERIALS{1,1,6} = 'COMPONENT:       CB_A';
MATERIALS{2,1,6} = 'STATE:           S';
MATERIALS{3,1,6} = 'DENSITY:         10000  0  0  0';
MATERIALS{4,1,6} = 'HEAT CAPACITY:   5230  -6.71  0.011  2';
MATERIALS{5,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,1,6} = ' ';

MATERIALS{1,2,6} = 'COMPONENT:       CB_B1';
MATERIALS{2,2,6} = 'STATE:           S';
MATERIALS{3,2,6} = 'DENSITY:         520  0  0  0';
MATERIALS{4,2,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,2,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,2,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,2,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,2,6} = ' ';

MATERIALS{1,3,6} = 'COMPONENT:       CB_B2';
MATERIALS{2,3,6} = 'STATE:           S';
MATERIALS{3,3,6} = 'DENSITY:         49  0  0  0';
MATERIALS{4,3,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,3,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,3,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,3,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,3,6} = ' ';

MATERIALS{1,4,6} = 'COMPONENT:       CB_B3';
MATERIALS{2,4,6} = 'STATE:           S';
MATERIALS{3,4,6} = 'DENSITY:         74  0  0  0';
MATERIALS{4,4,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,4,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,4,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,4,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,4,6} = ' ';

MATERIALS{1,5,6} = 'COMPONENT:       CB_C1';
MATERIALS{2,5,6} = 'STATE:           S';
MATERIALS{3,5,6} = 'DENSITY:         468  0  0  0';
MATERIALS{4,5,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{5,5,6} = 'CONDUCTIVITY:    0.05  0  7.5e-11  3';
MATERIALS{6,5,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,5,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{8,5,6} = ' ';

MATERIALS{1,6,6} = 'COMPONENT:       CB_C2';
MATERIALS{2,6,6} = 'STATE:           S';
MATERIALS{3,6,6} = 'DENSITY:         44  0  0  0';
MATERIALS{4,6,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{5,6,6} = 'CONDUCTIVITY:    0.05  0  7.5e-10  3';
MATERIALS{6,6,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,6,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{8,6,6} = ' ';

MATERIALS{1,7,6} = 'COMPONENT:       CB_C3';
MATERIALS{2,7,6} = 'STATE:           S';
MATERIALS{3,7,6} = 'DENSITY:         67  0  0  0';
MATERIALS{4,7,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{5,7,6} = 'CONDUCTIVITY:    0.05  0  7.5e-10  3';
MATERIALS{6,7,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,7,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{8,7,6} = ' ';

MATERIALS{1,8,6} = 'COMPONENT:       CB_ch1';
MATERIALS{2,8,6} = 'STATE:           S';
MATERIALS{3,8,6} = 'DENSITY:         173  0  0  0';
MATERIALS{4,8,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,8,6} = 'CONDUCTIVITY:    0  0  1.5e-10  3';
MATERIALS{6,8,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,8,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,8,6} = ' ';

MATERIALS{1,9,6} = 'COMPONENT:       CB_ch2';
MATERIALS{2,9,6} = 'STATE:           S';
MATERIALS{3,9,6} = 'DENSITY:         16  0  0  0';
MATERIALS{4,9,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,9,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{6,9,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,9,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,9,6} = ' ';

MATERIALS{1,10,6} = 'COMPONENT:       CB_ch3';
MATERIALS{2,10,6} = 'STATE:           S';
MATERIALS{3,10,6} = 'DENSITY:         25  0  0  0';
MATERIALS{4,10,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,10,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{6,10,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,10,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,10,6} = ' ';

MATERIALS{1,11,6} = 'COMPONENT:       CB_ch4';
MATERIALS{2,11,6} = 'STATE:           S';
MATERIALS{3,11,6} = 'DENSITY:         102  0  0  0';
MATERIALS{4,11,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,11,6} = 'CONDUCTIVITY:    0  0  1.5e-10  3';
MATERIALS{6,11,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,11,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,11,6} = ' ';

MATERIALS{1,12,6} = 'COMPONENT:       CB_ch5';
MATERIALS{2,12,6} = 'STATE:           S';
MATERIALS{3,12,6} = 'DENSITY:         9.4  0  0  0';
MATERIALS{4,12,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,12,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{6,12,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,12,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,12,6} = ' ';

MATERIALS{1,13,6} = 'COMPONENT:       CB_ch6';
MATERIALS{2,13,6} = 'STATE:           S';
MATERIALS{3,13,6} = 'DENSITY:         14.8  0  0  0';
MATERIALS{4,13,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,13,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{6,13,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,13,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{8,13,6} = ' ';

MATERIALS{1,14,6} = 'COMPONENT:       CB_g_1';
MATERIALS{2,14,6} = 'STATE:           G';
MATERIALS{3,14,6} = 'DENSITY:         10000  0  0  0';
MATERIALS{4,14,6} = 'HEAT CAPACITY:   2398  -1.6  0.0016  2';
MATERIALS{5,14,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,14,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,14,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,14,6} = ' ';

MATERIALS{1,15,6} = 'COMPONENT:       CB_g_2';
MATERIALS{2,15,6} = 'STATE:           G';
MATERIALS{3,15,6} = 'DENSITY:         10000  0  0  0';
MATERIALS{4,15,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{5,15,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{6,15,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,15,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{8,15,6} = ' ';

MATERIALS{1,16,6} = 'REACTION:       CB_A + NOCOMP -> NOCOMP + CB_g_1';
MATERIALS{2,16,6} = 'STOICHIOMETRY:  1      0         0        1';
MATERIALS{3,16,6} = 'ARRHENIUS:      6.14e0  2.35e4';
MATERIALS{4,16,6} = 'HEAT:           -24.45e5  0  0  0';
MATERIALS{5,16,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,16,6} = ' ';

MATERIALS{1,17,6} = 'REACTION:       CB_B1 + NOCOMP -> CB_C1 + CB_g_2';
MATERIALS{2,17,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{3,17,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{4,17,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,17,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,17,6} = ' ';

MATERIALS{1,18,6} = 'REACTION:       CB_B2 + NOCOMP -> CB_C2 + CB_g_2';
MATERIALS{2,18,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{3,18,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{4,18,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,18,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,18,6} = ' ';

MATERIALS{1,19,6} = 'REACTION:       CB_B3 + NOCOMP -> CB_C3 + CB_g_2';
MATERIALS{2,19,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{3,19,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{4,19,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,19,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,19,6} = ' ';

MATERIALS{1,20,6} = 'REACTION:       CB_C1 + NOCOMP -> CB_ch1 + CB_g_2';
MATERIALS{2,20,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{3,20,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{4,20,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{5,20,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,20,6} = ' ';

MATERIALS{1,21,6} = 'REACTION:       CB_C2 + NOCOMP -> CB_ch2 + CB_g_2';
MATERIALS{2,21,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{3,21,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{4,21,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{5,21,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,21,6} = ' ';

MATERIALS{1,22,6} = 'REACTION:       CB_C3 + NOCOMP -> CB_ch3 + CB_g_2';
MATERIALS{2,22,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{3,22,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{4,22,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{5,22,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,22,6} = ' ';

MATERIALS{1,23,6} = 'REACTION:       CB_ch1 + NOCOMP -> CB_ch4 + CB_g_2';
MATERIALS{2,23,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{3,23,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{4,23,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,23,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,23,6} = ' ';

MATERIALS{1,24,6} = 'REACTION:       CB_ch2 + NOCOMP -> CB_ch5 + CB_g_2';
MATERIALS{2,24,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{3,24,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{4,24,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,24,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,24,6} = ' ';

MATERIALS{1,25,6} = 'REACTION:       CB_ch3 + NOCOMP -> CB_ch6 + CB_g_2';
MATERIALS{2,25,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{3,25,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{4,25,6} = 'HEAT:           0  0  0  0';
MATERIALS{5,25,6} = 'TEMP LIMIT:     L  300';
%%
%% PEI
MATERIALS{1,1,7} = 'COMPONENT:       PEI';
MATERIALS{2,1,7} = 'STATE:           S';
MATERIALS{3,1,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{4,1,7} = 'HEAT CAPACITY:   -35.71  4.11  0  0';
MATERIALS{5,1,7} = 'CONDUCTIVITY:    0.4  -0.0004  0  0';
MATERIALS{6,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,7} = 'EMISSIVITY & ABSORPTION:  0.95  1.36';
MATERIALS{8,1,7} = ' ';

MATERIALS{1,2,7} = 'COMPONENT:       PEI_melt';
MATERIALS{2,2,7} = 'STATE:           S';
MATERIALS{3,2,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{4,2,7} = 'HEAT CAPACITY:   1877.15  0.57487  0  0';
MATERIALS{5,2,7} = 'CONDUCTIVITY:    0.32  -0.00033  0  0';
MATERIALS{6,2,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,7} = 'EMISSIVITY & ABSORPTION:  0.95  100';
MATERIALS{8,2,7} = ' ';

MATERIALS{1,3,7} = 'COMPONENT:       PEI_1';
MATERIALS{2,3,7} = 'STATE:           S';
MATERIALS{3,3,7} = 'DENSITY:         80  0  0  0';
MATERIALS{4,3,7} = 'HEAT CAPACITY:   1585  0.308  0  0';
MATERIALS{5,3,7} = 'CONDUCTIVITY:    0.45  0.00019  0  0';
MATERIALS{6,3,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,7} = 'EMISSIVITY & ABSORPTION:  0.95  100';
MATERIALS{8,3,7} = ' ';

MATERIALS{1,4,7} = 'COMPONENT:       PEI_ch';
MATERIALS{2,4,7} = 'STATE:           S';
MATERIALS{3,4,7} = 'DENSITY:         80  0  0  0';
MATERIALS{4,4,7} = 'HEAT CAPACITY:   1300  0.0408  0  0';
MATERIALS{5,4,7} = 'CONDUCTIVITY:    0.5  -3.4e-5  2.0e-10  3';
MATERIALS{6,4,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,7} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{8,4,7} = ' ';

MATERIALS{1,5,7} = 'COMPONENT:       PEI_g1';
MATERIALS{2,5,7} = 'STATE:           G';
MATERIALS{3,5,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{4,5,7} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,5,7} = 'CONDUCTIVITY:    0.4  -0.0004  0  0';
MATERIALS{6,5,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,5,7} = 'EMISSIVITY & ABSORPTION:  0.95  1.36';
MATERIALS{8,5,7} = ' ';

MATERIALS{1,6,7} = 'COMPONENT:       PEI_g2';
MATERIALS{2,6,7} = 'STATE:           G';
MATERIALS{3,6,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{4,6,7} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,6,7} = 'CONDUCTIVITY:    0.4  -0.0004  0  0';
MATERIALS{6,6,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,6,7} = 'EMISSIVITY & ABSORPTION:  0.95  1.36';
MATERIALS{8,6,7} = ' ';

MATERIALS{1,7,7} = 'REACTION:       PEI + NOCOMP -> PEI_melt + PEI_g1';
MATERIALS{2,7,7} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,7,7} = 'ARRHENIUS:      1  0';
MATERIALS{4,7,7} = 'HEAT:           0  0  0  0';
MATERIALS{5,7,7} = 'TEMP LIMIT:     L  496';
MATERIALS{6,7,7} = ' ';

MATERIALS{1,8,7} = 'REACTION:       PEI_melt + NOCOMP -> PEI_1 + PEI_g1';
MATERIALS{2,8,7} = 'STOICHIOMETRY:  1    0         0.65    0.35';
MATERIALS{3,8,7} = 'ARRHENIUS:      7.655e27  465000';
MATERIALS{4,8,7} = 'HEAT:           80000  0  0  0';
MATERIALS{5,8,7} = 'TEMP LIMIT:     L  300';
MATERIALS{6,8,7} = ' ';

MATERIALS{1,9,7} = 'REACTION:       PEI_1 + NOCOMP -> PEI_ch + PEI_g2';
MATERIALS{2,9,7} = 'STOICHIOMETRY:  1    0         0.77    0.23';
MATERIALS{3,9,7} = 'ARRHENIUS:      6.502e02  87500';
MATERIALS{4,9,7} = 'HEAT:           5000  0  0  0';
MATERIALS{5,9,7} = 'TEMP LIMIT:     L  300';
%%
%% PET
MATERIALS{1,1,8} = 'COMPONENT:       PET';
MATERIALS{2,1,8} = 'STATE:           S';
MATERIALS{3,1,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{4,1,8} = 'HEAT CAPACITY:   -268.62  4.64  0  0';
MATERIALS{5,1,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{6,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,1,8} = ' ';

MATERIALS{1,2,8} = 'COMPONENT:       PET_melt';
MATERIALS{2,2,8} = 'STATE:           S';
MATERIALS{3,2,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{4,2,8} = 'HEAT CAPACITY:   2050.013  -0.208288  0  0';
MATERIALS{5,2,8} = 'CONDUCTIVITY:    0.325  -0.00002  0  0';
MATERIALS{6,2,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,2,8} = ' ';

MATERIALS{1,3,8} = 'COMPONENT:       PET_inter';
MATERIALS{2,3,8} = 'STATE:           S';
MATERIALS{3,3,8} = 'DENSITY:         730  0  0  0';
MATERIALS{4,3,8} = 'HEAT CAPACITY:   1435  -0.048  0  0';
MATERIALS{5,3,8} = 'CONDUCTIVITY:    0.45  0.0002  0  0';
MATERIALS{6,3,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,3,8} = ' ';

MATERIALS{1,4,8} = 'COMPONENT:       PET_ch';
MATERIALS{2,4,8} = 'STATE:           S';
MATERIALS{3,4,8} = 'DENSITY:         80  0  0  0';
MATERIALS{4,4,8} = 'HEAT CAPACITY:   820  0.112  0  0';
MATERIALS{5,4,8} = 'CONDUCTIVITY:    0.45  3.8e-5  5.0e-10  3';
MATERIALS{6,4,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,8} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{8,4,8} = ' ';

MATERIALS{1,5,8} = 'COMPONENT:       PET_g1';
MATERIALS{2,5,8} = 'STATE:           G';
MATERIALS{3,5,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{4,5,8} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,5,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{6,5,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,5,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,5,8} = ' ';

MATERIALS{1,6,8} = 'COMPONENT:       PET_g2';
MATERIALS{2,6,8} = 'STATE:           G';
MATERIALS{3,6,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{4,6,8} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,6,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{6,6,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,6,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,6,8} = ' ';

MATERIALS{1,7,8} = 'REACTION:       PET + NOCOMP -> PET_melt + PET_g1';
MATERIALS{2,7,8} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,7,8} = 'ARRHENIUS:      1.5E36  380000';
MATERIALS{4,7,8} = 'HEAT:           -30310  0  0  0';
MATERIALS{5,7,8} = 'TEMP LIMIT:     L  300';
MATERIALS{5,7,8} = ' ';

MATERIALS{1,8,8} = 'REACTION:       PET_melt + NOCOMP -> PET_inter + PET_g1';
MATERIALS{2,8,8} = 'STOICHIOMETRY:  1    0         0.18    0.82';
MATERIALS{3,8,8} = 'ARRHENIUS:      1.6e15  235000';
MATERIALS{4,8,8} = 'HEAT:           -220000  0  0  0';
MATERIALS{5,8,8} = 'TEMP LIMIT:     L  300';
MATERIALS{5,8,8} = ' ';

MATERIALS{1,9,8} = 'REACTION:       PET_inter + NOCOMP -> PET_ch + PET_g2';
MATERIALS{2,9,8} = 'STOICHIOMETRY:  1    0         0.72    0.28';
MATERIALS{3,9,8} = 'ARRHENIUS:      3.53e4  96000';
MATERIALS{4,9,8} = 'HEAT:           -250000  0  0  0';
MATERIALS{5,9,8} = 'TEMP LIMIT:     L  300';
%%
%% POM
MATERIALS{1,1,9} = 'COMPONENT:       POM';
MATERIALS{2,1,9} = 'STATE:           S';
MATERIALS{3,1,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{4,1,9} = 'HEAT CAPACITY:   -1861.4  9.98  0  0';
MATERIALS{5,1,9} = 'CONDUCTIVITY:    0.25  0.000016  0  0';
MATERIALS{6,1,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,9} = 'EMISSIVITY & ABSORPTION:  0.95  2.14';
MATERIALS{8,1,9} = ' ';

MATERIALS{1,2,9} = 'COMPONENT:       POM_melt';
MATERIALS{2,2,9} = 'STATE:           S';
MATERIALS{3,2,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{4,2,9} = 'HEAT CAPACITY:   1649  1.15  0  0';
MATERIALS{5,2,9} = 'CONDUCTIVITY:    0.21  0.000008  0  0';
MATERIALS{6,2,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,9} = 'EMISSIVITY & ABSORPTION:  0.95  2.14';
MATERIALS{8,2,9} = ' ';

MATERIALS{1,3,9} = 'COMPONENT:       POM_inter';
MATERIALS{2,3,9} = 'STATE:           S';
MATERIALS{3,3,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{4,3,9} = 'HEAT CAPACITY:   1649 1.15  0  0';
MATERIALS{5,3,9} = 'CONDUCTIVITY:    0.19  -0.00006  0  0';
MATERIALS{6,3,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,9} = 'EMISSIVITY & ABSORPTION:  0.95  2.14';
MATERIALS{8,3,9} = ' ';

MATERIALS{1,4,9} = 'COMPONENT:       POM_ch';
MATERIALS{2,4,9} = 'STATE:           S';
MATERIALS{3,4,9} = 'DENSITY:         265  0  0  0';
MATERIALS{4,4,9} = 'HEAT CAPACITY:   1250  0  0  0';
MATERIALS{5,4,9} = 'CONDUCTIVITY:    0.5  0  0  0';
MATERIALS{6,4,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,9} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{8,4,9} = ' ';

MATERIALS{1,5,9} = 'COMPONENT:       POM_g1';
MATERIALS{2,5,9} = 'STATE:           G';
MATERIALS{3,5,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{4,5,9} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{5,5,9} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{6,5,9} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,5,9} = 'EMISSIVITY & ABSORPTION:  1  2.14';
MATERIALS{8,5,9} = ' ';

MATERIALS{1,6,9} = 'COMPONENT:       POM_g2';
MATERIALS{2,6,9} = 'STATE:           G';
MATERIALS{3,6,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{4,6,9} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{5,6,9} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{6,6,9} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{7,6,9} = 'EMISSIVITY & ABSORPTION:  1  2.14';
MATERIALS{8,6,9} = ' ';

MATERIALS{1,7,9} = 'REACTION:       POM + NOCOMP -> POM_melt + POM_g1';
MATERIALS{2,7,9} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,7,9} = 'ARRHENIUS:      2.69e42  382000';
MATERIALS{4,7,9} = 'HEAT:           -192100  0  0  0';
MATERIALS{5,7,9} = 'TEMP LIMIT:     L  300';
MATERIALS{6,7,9} = ' ';

MATERIALS{1,8,9} = 'REACTION:       POM_melt + NOCOMP -> POM_inter + POM_g1';
MATERIALS{2,8,9} = 'STOICHIOMETRY:  1    0         0.4    0.6';
MATERIALS{3,8,9} = 'ARRHENIUS:      3.835e14  200000';
MATERIALS{4,8,9} = 'HEAT:           -1192000  0  0  0';
MATERIALS{5,8,9} = 'TEMP LIMIT:     L  300';
MATERIALS{6,8,9} = ' ';

MATERIALS{1,9,9} = 'REACTION:       POM_inter + NOCOMP -> POM_ch + POM_g2';
MATERIALS{2,9,9} = 'STOICHIOMETRY:  1    0         0    1';
MATERIALS{3,9,9} = 'ARRHENIUS:       4.758378e44  590000';
MATERIALS{4,9,9} = 'HEAT:           -1352000  0  0  0';
MATERIALS{5,9,9} = 'TEMP LIMIT:     L  300';
%% 
%% ABS
MATERIALS{1,1,10} = 'COMPONENT:       ABS';
MATERIALS{2,1,10} = 'STATE:           S';
MATERIALS{3,1,10} = 'DENSITY:         1050  0  0  0';
MATERIALS{4,1,10} = 'HEAT CAPACITY:   1579.5  1.26  0  0';
MATERIALS{5,1,10} = 'CONDUCTIVITY:    0.30  -0.00028  0  0';
MATERIALS{6,1,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,10} = 'EMISSIVITY & ABSORPTION:  0.95  1.71';
MATERIALS{8,1,10} = ' ';

MATERIALS{1,2,10} = 'COMPONENT:       ABS_glass';
MATERIALS{2,2,10} = 'STATE:           S';
MATERIALS{3,2,10} = 'DENSITY:         1050  0  0  0';
MATERIALS{4,2,10} = 'HEAT CAPACITY:   1579.5  1.26  0  0';
MATERIALS{5,2,10} = 'CONDUCTIVITY:    0.21  -0.00026  0  0';
MATERIALS{6,2,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,2,10} = 'EMISSIVITY & ABSORPTION:  0.95  1.71';
MATERIALS{8,2,10} = ' ';

MATERIALS{1,3,10} = 'COMPONENT:       ABS_ch';
MATERIALS{2,3,10} = 'STATE:           S';
MATERIALS{3,3,10} = 'DENSITY:         80  0  0  0';
MATERIALS{4,3,10} = 'HEAT CAPACITY:   820  0.112  0  0';
MATERIALS{5,3,10} = 'CONDUCTIVITY:    0.13  -5.4e-4  4.8e-9  3';
MATERIALS{6,3,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,3,10} = 'EMISSIVITY & ABSORPTION:  0.86  31.25';
MATERIALS{8,3,10} = ' ';

MATERIALS{1,4,10} = 'COMPONENT:       ABS_g';
MATERIALS{2,4,10} = 'STATE:           G';
MATERIALS{3,4,10} = 'DENSITY:         1050  0  0  0';
MATERIALS{4,4,10} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{5,4,10} = 'CONDUCTIVITY:    0.30  -0.00028  0  0';
MATERIALS{6,4,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,4,10} = 'EMISSIVITY & ABSORPTION:  0.95  1.71';
MATERIALS{8,4,10} = ' ';

MATERIALS{1,5,10} = 'REACTION:       ABS + NOCOMP -> ABS_ch + ABS_g';
MATERIALS{2,5,10} = 'STOICHIOMETRY:  1    0         0.023    0.977';
MATERIALS{3,5,10} = 'ARRHENIUS:      9.995e13  218500';
MATERIALS{4,5,10} = 'HEAT:           -460000  0  0  0';
MATERIALS{5,5,10} = 'TEMP LIMIT:     L  300';
%% 
%% MIXTURES
MATERIALS{1,1,11} = ' ';
MATERIALS{2,1,11} = 'MIXTURES';
MATERIALS{3,1,11} = 'S SWELLING:           0';
MATERIALS{4,1,11} = 'L SWELLING:           0';
MATERIALS{5,1,11} = 'G SWELLING LIMIT:     1e-30';
MATERIALS{6,1,11} = 'PARALL CONDUCTIVITY:  0.5';
MATERIALS{7,1,11} = 'PARALL TRANSPORT:     0.5';
%%
%% Components
KAOWOOL = strvcat(MATERIALS{:,:,1});
AL = strvcat(MATERIALS{:,:,2}); %#ok<*DSTRVCT>
PMMA = strvcat(MATERIALS{:,:,3});
HIPS = strvcat(MATERIALS{:,:,4});
Kydex = strvcat(MATERIALS{:,:,5});
CB = strvcat(MATERIALS{:,:,6});
PEI = strvcat(MATERIALS{:,:,7});
PET = strvcat(MATERIALS{:,:,8});
POM = strvcat(MATERIALS{:,:,9});
ABS = strvcat(MATERIALS{:,:,10});
%%

index_selected = get(hObject,'Value');
Materials = {ABS,AL,CB,HIPS,KAOWOOL,Kydex,PEI,PET,PMMA,POM};
RMAT = (Materials(index_selected)); %Selected info we want to show
FileName = uiputfile('*.cmp','Save as');
dlmwrite(FileName,index_selected,'');

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'ABS';'AL';'CB';'HIPS';'KAOWOOL';'Kydex';'PEI';'PET';'PMMA';'POM'});

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
popupmenu1_Callback(hObject,eventdata, handles);
