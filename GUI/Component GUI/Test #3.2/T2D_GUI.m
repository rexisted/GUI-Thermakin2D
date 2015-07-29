function varargout = T2D_GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T2D_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @T2D_GUI_OutputFcn, ...
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

% --- Executes just before T2D_GUI is made visible.
function T2D_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = T2D_GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function cmp_list_Callback(hObject, eventdata, handles)

function cmp_list_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'ABS';'Aluminum';'Cardboard';'HIPS';'KAOWOOL';'Kydex';'PEI';'PET';'PMMA';'POM'}); %visible name of materials in the GUI

function start1_Callback(hObject, eventdata, handles)
%% KAWOOL
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

MATERIALS{7,1,3} = 'COMPONENT:       PMMA_glass';
MATERIALS{8,1,3} = 'STATE:           S';
MATERIALS{9,1,3} = 'DENSITY:         1150  0  0  0';
MATERIALS{10,1,3} = 'HEAT CAPACITY:   601.4  3.63  0  0';
MATERIALS{11,1,3} = 'CONDUCTIVITY:    0.27 -2.4e-4  0  0';
MATERIALS{12,1,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{13,1,3} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{14,1,3} = ' ';

MATERIALS{15,1,3} = 'COMPONENT:       PMMA_ch';
MATERIALS{16,1,3} = 'STATE:           S';
MATERIALS{17,1,3} = 'DENSITY:         1180  0  0  0';
MATERIALS{18,1,3} = 'HEAT CAPACITY:   1000  0  0  0';
MATERIALS{19,1,3} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{20,1,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{21,1,3} = 'EMISSIVITY & ABSORPTION:  0  10000';
MATERIALS{22,1,3} = ' ';

MATERIALS{23,1,3} = 'COMPONENT:       PMMA_g';
MATERIALS{24,1,3} = 'STATE:           G';
MATERIALS{25,1,3} = 'DENSITY:         1  0  0  0';
MATERIALS{26,1,3} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{27,1,3} = 'CONDUCTIVITY:    8.876e-4  -1.16e-5  1.55e-7  2';
MATERIALS{28,1,3} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{29,1,3} = 'EMISSIVITY & ABSORPTION:  1  10000';
MATERIALS{30,1,3} = ' ';

MATERIALS{1,2,3} = 'REACTION:       PMMA + NOCOMP -> PMMA_glass + NOCOMP';
MATERIALS{2,2,3} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,2,3} = 'ARRHENIUS:      1  0';
MATERIALS{4,2,3} = 'HEAT:           0  0  0  0';
MATERIALS{5,2,3} = 'TEMP LIMIT:     L  378';
MATERIALS{5,2,3} = ' ';

MATERIALS{6,2,3} = 'REACTION:       PMMA_glass + NOCOMP -> PMMA_ch + PMMA_g';
MATERIALS{6,2,3} = 'STOICHIOMETRY:  1    0         0    1';
MATERIALS{6,2,3} = 'ARRHENIUS:      8.6e12  188100';
MATERIALS{6,2,3} = 'HEAT:           -846000  0  0  0';
MATERIALS{6,2,3} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,4} = 'COMPONENT:       HIPS_ch';
MATERIALS{10,1,4} = 'STATE:           S';
MATERIALS{11,1,4} = 'DENSITY:         265  0  0  0';
MATERIALS{12,1,4} = 'HEAT CAPACITY:   1250  0  0  0';
MATERIALS{13,1,4} = 'CONDUCTIVITY:    0.5  0  0  0';
MATERIALS{14,1,4} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,4} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{16,1,4} = ' ';

MATERIALS{17,1,4} = 'COMPONENT:       HIPS_g';
MATERIALS{18,1,4} = 'STATE:           G';
MATERIALS{19,1,4} = 'DENSITY:         1060  0  0  0';
MATERIALS{20,1,4} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{21,1,4} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{22,1,4} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,4} = 'EMISSIVITY & ABSORPTION:  1  2.12';
MATERIALS{24,1,4} = ' ';

MATERIALS{1,2,4} = 'REACTION:       HIPS + NOCOMP -> HIPS_ch + HIPS_g';
MATERIALS{2,2,4} = 'STOICHIOMETRY:  1    0         0.043    0.957';
MATERIALS{3,2,4} = 'ARRHENIUS:      1.705e20  300500';
MATERIALS{4,2,4} = 'HEAT:           -689000  0  0  0';
MATERIALS{5,2,4} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,5} = 'COMPONENT:       Kydex_1';
MATERIALS{10,1,5} = 'STATE:           S';
MATERIALS{11,1,5} = 'DENSITY:         100  0  0  0';
MATERIALS{12,1,5} = 'HEAT CAPACITY:   265  3.01  0  0';
MATERIALS{13,1,5} = 'CONDUCTIVITY:    0.55  0.00003  0  0';
MATERIALS{14,1,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,5} = 'EMISSIVITY & ABSORPTION:  0.95  30';
MATERIALS{16,1,5} = ' ';

MATERIALS{17,1,5} = 'COMPONENT:       Kydex_ch';
MATERIALS{18,1,5} = 'STATE:           S';
MATERIALS{19,1,5} = 'DENSITY:         100  0  0  0';
MATERIALS{20,1,5} = 'HEAT CAPACITY:   1150  0.0956  0  0';
MATERIALS{21,1,5} = 'CONDUCTIVITY:    0.28  8.4e-5  3.0e-10  3';
MATERIALS{22,1,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,5} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{24,1,5} = ' ';

MATERIALS{25,1,5} = 'COMPONENT:       Kydex_g1';
MATERIALS{26,1,5} = 'STATE:           G';
MATERIALS{27,1,5} = 'DENSITY:         1350  0  0  0';
MATERIALS{28,1,5} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{29,1,5} = 'CONDUCTIVITY:    0.28  -0.00028 0  0';
MATERIALS{30,1,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{31,1,5} = 'EMISSIVITY & ABSORPTION:  0.95  1.58';
MATERIALS{32,1,5} = ' ';

MATERIALS{33,1,5} = 'COMPONENT:       Kydex_g2';
MATERIALS{34,1,5} = 'STATE:           G';
MATERIALS{35,1,5} = 'DENSITY:         1350  0  0  0';
MATERIALS{36,1,5} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{37,1,5} = 'CONDUCTIVITY:    0.28  -0.00028 0  0';
MATERIALS{38,1,5} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{39,1,5} = 'EMISSIVITY & ABSORPTION:  0.95  1.58';
MATERIALS{40,1,5} = ' ';

MATERIALS{1,2,5} = 'REACTION:       Kydex + NOCOMP -> Kydex_1 + Kydex_g1';
MATERIALS{2,2,5} = 'STOICHIOMETRY:  1    0         0.45    0.55';
MATERIALS{3,2,5} = 'ARRHENIUS:      6.025e10  141000';
MATERIALS{4,2,5} = 'HEAT:           -180000  0  0  0';
MATERIALS{5,2,5} = 'TEMP LIMIT:     L  300';
MATERIALS{6,2,5} = ' ';

MATERIALS{7,2,5} = 'REACTION:       Kydex_1 + NOCOMP -> Kydex_ch + Kydex_g2';
MATERIALS{8,2,5} = 'STOICHIOMETRY:  1    0         0.31    0.69';
MATERIALS{9,2,5} = 'ARRHENIUS:      1.355e10  174000';
MATERIALS{10,2,5} = 'HEAT:           -124400  0  0  0';
MATERIALS{11,2,5} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,6} = 'COMPONENT:       CB_B1';
MATERIALS{10,1,6} = 'STATE:           S';
MATERIALS{11,1,6} = 'DENSITY:         520  0  0  0';
MATERIALS{12,1,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{13,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{14,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{15,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{16,1,6} = ' ';

MATERIALS{17,1,6} = 'COMPONENT:       CB_B2';
MATERIALS{18,1,6} = 'STATE:           S';
MATERIALS{19,1,6} = 'DENSITY:         49  0  0  0';
MATERIALS{20,1,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{21,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{22,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{23,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{24,1,6} = ' ';

MATERIALS{25,1,6} = 'COMPONENT:       CB_B3';
MATERIALS{26,1,6} = 'STATE:           S';
MATERIALS{27,1,6} = 'DENSITY:         74  0  0  0';
MATERIALS{28,1,6} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{29,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{30,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{31,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{32,1,6} = ' ';

MATERIALS{33,1,6} = 'COMPONENT:       CB_C1';
MATERIALS{34,1,6} = 'STATE:           S';
MATERIALS{35,1,6} = 'DENSITY:         468  0  0  0';
MATERIALS{36,1,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{37,1,6} = 'CONDUCTIVITY:    0.05  0  7.5e-11  3';
MATERIALS{38,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{39,1,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{40,1,6} = ' ';

MATERIALS{41,1,6} = 'COMPONENT:       CB_C2';
MATERIALS{42,1,6} = 'STATE:           S';
MATERIALS{43,1,6} = 'DENSITY:         44  0  0  0';
MATERIALS{44,1,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{45,1,6} = 'CONDUCTIVITY:    0.05  0  7.5e-10  3';
MATERIALS{46,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{47,1,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{48,1,6} = ' ';

MATERIALS{49,1,6} = 'COMPONENT:       CB_C3';
MATERIALS{50,1,6} = 'STATE:           S';
MATERIALS{51,1,6} = 'DENSITY:         67  0  0  0';
MATERIALS{52,1,6} = 'HEAT CAPACITY:   1540  0  0  0';
MATERIALS{53,1,6} = 'CONDUCTIVITY:    0.05  0  7.5e-10  3';
MATERIALS{54,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{55,1,6} = 'EMISSIVITY & ABSORPTION:  0.775  100';
MATERIALS{56,1,6} = ' ';

MATERIALS{57,1,6} = 'COMPONENT:       CB_ch1';
MATERIALS{58,1,6} = 'STATE:           S';
MATERIALS{59,1,6} = 'DENSITY:         173  0  0  0';
MATERIALS{60,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{61,1,6} = 'CONDUCTIVITY:    0  0  1.5e-10  3';
MATERIALS{62,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{63,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{64,1,6} = ' ';

MATERIALS{65,1,6} = 'COMPONENT:       CB_ch2';
MATERIALS{66,1,6} = 'STATE:           S';
MATERIALS{67,1,6} = 'DENSITY:         16  0  0  0';
MATERIALS{68,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{69,1,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{70,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{71,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{72,1,6} = ' ';

MATERIALS{73,1,6} = 'COMPONENT:       CB_ch3';
MATERIALS{74,1,6} = 'STATE:           S';
MATERIALS{75,1,6} = 'DENSITY:         25  0  0  0';
MATERIALS{76,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{77,1,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{78,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{79,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{80,1,6} = ' ';

MATERIALS{81,1,6} = 'COMPONENT:       CB_ch4';
MATERIALS{82,1,6} = 'STATE:           S';
MATERIALS{83,1,6} = 'DENSITY:         102  0  0  0';
MATERIALS{84,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{85,1,6} = 'CONDUCTIVITY:    0  0  1.5e-10  3';
MATERIALS{86,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{87,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{88,1,6} = ' ';

MATERIALS{89,1,6} = 'COMPONENT:       CB_ch5';
MATERIALS{90,1,6} = 'STATE:           S';
MATERIALS{91,1,6} = 'DENSITY:         9.4  0  0  0';
MATERIALS{92,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{93,1,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{94,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{95,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{96,1,6} = ' ';

MATERIALS{97,1,6} = 'COMPONENT:       CB_ch6';
MATERIALS{98,1,6} = 'STATE:           S';
MATERIALS{99,1,6} = 'DENSITY:         14.8  0  0  0';
MATERIALS{100,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{101,1,6} = 'CONDUCTIVITY:    0  0  1.5e-9  3';
MATERIALS{102,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{103,1,6} = 'EMISSIVITY & ABSORPTION:  0.85  100';
MATERIALS{104,1,6} = ' ';

MATERIALS{105,1,6} = 'COMPONENT:       CB_g_1';
MATERIALS{106,1,6} = 'STATE:           G';
MATERIALS{107,1,6} = 'DENSITY:         10000  0  0  0';
MATERIALS{108,1,6} = 'HEAT CAPACITY:   2398  -1.6  0.0016  2';
MATERIALS{109,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{110,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{111,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{112,1,6} = ' ';

MATERIALS{113,1,6} = 'COMPONENT:       CB_g_2';
MATERIALS{114,1,6} = 'STATE:           G';
MATERIALS{115,1,6} = 'DENSITY:         10000  0  0  0';
MATERIALS{116,1,6} = 'HEAT CAPACITY:   1280  0  0  0';
MATERIALS{117,1,6} = 'CONDUCTIVITY:    0.1  0  0  0';
MATERIALS{118,1,6} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{119,1,6} = 'EMISSIVITY & ABSORPTION:  0.7  100';
MATERIALS{120,1,6} = ' ';

MATERIALS{1,2,6} = 'REACTION:       CB_A + NOCOMP -> NOCOMP + CB_g_1';
MATERIALS{2,2,6} = 'STOICHIOMETRY:  1      0         0        1';
MATERIALS{3,2,6} = 'ARRHENIUS:      6.14e0  2.35e4';
MATERIALS{4,2,6} = 'HEAT:           -24.45e5  0  0  0';
MATERIALS{5,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{6,2,6} = ' ';

MATERIALS{7,2,6} = 'REACTION:       CB_B1 + NOCOMP -> CB_C1 + CB_g_2';
MATERIALS{8,2,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{9,2,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{10,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{11,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{12,2,6} = ' ';

MATERIALS{13,2,6} = 'REACTION:       CB_B2 + NOCOMP -> CB_C2 + CB_g_2';
MATERIALS{14,2,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{15,2,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{16,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{17,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{18,2,6} = ' ';

MATERIALS{19,2,6} = 'REACTION:       CB_B3 + NOCOMP -> CB_C3 + CB_g_2';
MATERIALS{20,2,6} = 'STOICHIOMETRY:  1      0         0.9     0.1';
MATERIALS{21,2,6} = 'ARRHENIUS:      7.95e9  1.3e5';
MATERIALS{22,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{23,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{24,2,6} = ' ';

MATERIALS{25,2,6} = 'REACTION:       CB_C1 + NOCOMP -> CB_ch1 + CB_g_2';
MATERIALS{26,2,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{27,2,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{28,2,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{29,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{30,2,6} = ' ';

MATERIALS{31,2,6} = 'REACTION:       CB_C2 + NOCOMP -> CB_ch2 + CB_g_2';
MATERIALS{32,2,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{33,2,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{34,2,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{35,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{36,2,6} = ' ';

MATERIALS{37,2,6} = 'REACTION:       CB_C3 + NOCOMP -> CB_ch3 + CB_g_2';
MATERIALS{38,2,6} = 'STOICHIOMETRY:  1      0         0.37     0.63';
MATERIALS{39,2,6} = 'ARRHENIUS:      2e11  1.6e5';
MATERIALS{40,2,6} = 'HEAT:           -1.26e5  0  0  0';
MATERIALS{41,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{42,2,6} = ' ';

MATERIALS{43,2,6} = 'REACTION:       CB_ch1 + NOCOMP -> CB_ch4 + CB_g_2';
MATERIALS{44,2,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{45,2,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{46,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{47,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{48,2,6} = ' ';

MATERIALS{49,2,6} = 'REACTION:       CB_ch2 + NOCOMP -> CB_ch5 + CB_g_2';
MATERIALS{50,2,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{51,2,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{52,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{53,2,6} = 'TEMP LIMIT:     L  300';
MATERIALS{54,2,6} = ' ';

MATERIALS{55,2,6} = 'REACTION:       CB_ch3 + NOCOMP -> CB_ch6 + CB_g_2';
MATERIALS{56,2,6} = 'STOICHIOMETRY:  1      0         0.59     0.41';
MATERIALS{57,2,6} = 'ARRHENIUS:      2.61e-2  1.7e4';
MATERIALS{58,2,6} = 'HEAT:           0  0  0  0';
MATERIALS{59,2,6} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,7} = 'COMPONENT:       PEI_melt';
MATERIALS{10,1,7} = 'STATE:           S';
MATERIALS{11,1,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{12,1,7} = 'HEAT CAPACITY:   1877.15  0.57487  0  0';
MATERIALS{13,1,7} = 'CONDUCTIVITY:    0.32  -0.00033  0  0';
MATERIALS{14,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,7} = 'EMISSIVITY & ABSORPTION:  0.95  100';
MATERIALS{16,1,7} = ' ';

MATERIALS{17,1,7} = 'COMPONENT:       PEI_1';
MATERIALS{18,1,7} = 'STATE:           S';
MATERIALS{19,1,7} = 'DENSITY:         80  0  0  0';
MATERIALS{20,1,7} = 'HEAT CAPACITY:   1585  0.308  0  0';
MATERIALS{21,1,7} = 'CONDUCTIVITY:    0.45  0.00019  0  0';
MATERIALS{22,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,7} = 'EMISSIVITY & ABSORPTION:  0.95  100';
MATERIALS{24,1,7} = ' ';

MATERIALS{25,1,7} = 'COMPONENT:       PEI_ch';
MATERIALS{26,1,7} = 'STATE:           S';
MATERIALS{27,1,7} = 'DENSITY:         80  0  0  0';
MATERIALS{28,1,7} = 'HEAT CAPACITY:   1300  0.0408  0  0';
MATERIALS{29,1,7} = 'CONDUCTIVITY:    0.5  -3.4e-5  2.0e-10  3';
MATERIALS{30,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{31,1,7} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{32,1,7} = ' ';

MATERIALS{33,1,7} = 'COMPONENT:       PEI_g1';
MATERIALS{34,1,7} = 'STATE:           G';
MATERIALS{35,1,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{36,1,7} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{37,1,7} = 'CONDUCTIVITY:    0.4  -0.0004  0  0';
MATERIALS{38,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{39,1,7} = 'EMISSIVITY & ABSORPTION:  0.95  1.36';
MATERIALS{40,1,7} = ' ';

MATERIALS{41,1,7} = 'COMPONENT:       PEI_g2';
MATERIALS{42,1,7} = 'STATE:           G';
MATERIALS{43,1,7} = 'DENSITY:         1285  0  0  0';
MATERIALS{44,1,7} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{45,1,7} = 'CONDUCTIVITY:    0.4  -0.0004  0  0';
MATERIALS{46,1,7} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{47,1,7} = 'EMISSIVITY & ABSORPTION:  0.95  1.36';
MATERIALS{48,1,7} = ' ';

MATERIALS{1,2,7} = 'REACTION:       PEI + NOCOMP -> PEI_melt + PEI_g1';
MATERIALS{2,2,7} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,2,7} = 'ARRHENIUS:      1  0';
MATERIALS{4,2,7} = 'HEAT:           0  0  0  0';
MATERIALS{5,2,7} = 'TEMP LIMIT:     L  496';
MATERIALS{6,2,7} = ' ';

MATERIALS{7,2,7} = 'REACTION:       PEI_melt + NOCOMP -> PEI_1 + PEI_g1';
MATERIALS{8,2,7} = 'STOICHIOMETRY:  1    0         0.65    0.35';
MATERIALS{9,2,7} = 'ARRHENIUS:      7.655e27  465000';
MATERIALS{10,2,7} = 'HEAT:           80000  0  0  0';
MATERIALS{11,2,7} = 'TEMP LIMIT:     L  300';
MATERIALS{12,2,7} = ' ';

MATERIALS{13,2,7} = 'REACTION:       PEI_1 + NOCOMP -> PEI_ch + PEI_g2';
MATERIALS{14,2,7} = 'STOICHIOMETRY:  1    0         0.77    0.23';
MATERIALS{15,2,7} = 'ARRHENIUS:      6.502e02  87500';
MATERIALS{16,2,7} = 'HEAT:           5000  0  0  0';
MATERIALS{17,2,7} = 'TEMP LIMIT:     L  300';
%%-
%% PET
MATERIALS{1,1,8} = 'COMPONENT:       PET';
MATERIALS{2,1,8} = 'STATE:           S';
MATERIALS{3,1,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{4,1,8} = 'HEAT CAPACITY:   -268.62  4.64  0  0';
MATERIALS{5,1,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{6,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{7,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{8,1,8} = ' ';

MATERIALS{9,1,8} = 'COMPONENT:       PET_melt';
MATERIALS{10,1,8} = 'STATE:           S';
MATERIALS{11,1,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{12,1,8} = 'HEAT CAPACITY:   2050.013  -0.208288  0  0';
MATERIALS{13,1,8} = 'CONDUCTIVITY:    0.325  -0.00002  0  0';
MATERIALS{14,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{16,1,8} = ' ';

MATERIALS{17,1,8} = 'COMPONENT:       PET_inter';
MATERIALS{18,1,8} = 'STATE:           S';
MATERIALS{19,1,8} = 'DENSITY:         730  0  0  0';
MATERIALS{20,1,8} = 'HEAT CAPACITY:   1435  -0.048  0  0';
MATERIALS{21,1,8} = 'CONDUCTIVITY:    0.45  0.0002  0  0';
MATERIALS{22,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{24,1,8} = ' ';

MATERIALS{25,1,8} = 'COMPONENT:       PET_ch';
MATERIALS{26,1,8} = 'STATE:           S';
MATERIALS{27,1,8} = 'DENSITY:         80  0  0  0';
MATERIALS{28,1,8} = 'HEAT CAPACITY:   820  0.112  0  0';
MATERIALS{29,1,8} = 'CONDUCTIVITY:    0.45  3.8e-5  5.0e-10  3';
MATERIALS{30,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{31,1,8} = 'EMISSIVITY & ABSORPTION:  0.86  100';
MATERIALS{32,1,8} = ' ';

MATERIALS{33,1,8} = 'COMPONENT:       PET_g1';
MATERIALS{34,1,8} = 'STATE:           G';
MATERIALS{35,1,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{36,1,8} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{37,1,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{38,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{39,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{40,1,8} = ' ';

MATERIALS{41,1,8} = 'COMPONENT:       PET_g2';
MATERIALS{42,1,8} = 'STATE:           G';
MATERIALS{43,1,8} = 'DENSITY:         1385  0  0  0';
MATERIALS{44,1,8} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{45,1,8} = 'CONDUCTIVITY:    0.35  -0.00048  0  0';
MATERIALS{46,1,8} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{47,1,8} = 'EMISSIVITY & ABSORPTION:  0.95  1.4';
MATERIALS{48,1,8} = ' ';

MATERIALS{1,2,8} = 'REACTION:       PET + NOCOMP -> PET_melt + PET_g1';
MATERIALS{2,2,8} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,2,8} = 'ARRHENIUS:      1.5E36  380000';
MATERIALS{4,2,8} = 'HEAT:           -30310  0  0  0';
MATERIALS{5,2,8} = 'TEMP LIMIT:     L  300';
MATERIALS{6,2,8} = ' ';

MATERIALS{7,2,8} = 'REACTION:       PET_melt + NOCOMP -> PET_inter + PET_g1';
MATERIALS{8,2,8} = 'STOICHIOMETRY:  1    0         0.18    0.82';
MATERIALS{9,2,8} = 'ARRHENIUS:      1.6e15  235000';
MATERIALS{10,2,8} = 'HEAT:           -220000  0  0  0';
MATERIALS{11,2,8} = 'TEMP LIMIT:     L  300';
MATERIALS{12,2,8} = ' ';

MATERIALS{13,2,8} = 'REACTION:       PET_inter + NOCOMP -> PET_ch + PET_g2';
MATERIALS{14,2,8} = 'STOICHIOMETRY:  1    0         0.72    0.28';
MATERIALS{15,2,8} = 'ARRHENIUS:      3.53e4  96000';
MATERIALS{16,2,8} = 'HEAT:           -250000  0  0  0';
MATERIALS{17,2,8} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,9} = 'COMPONENT:       POM_melt';
MATERIALS{10,1,9} = 'STATE:           S';
MATERIALS{11,1,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{12,1,9} = 'HEAT CAPACITY:   1649  1.15  0  0';
MATERIALS{13,1,9} = 'CONDUCTIVITY:    0.21  0.000008  0  0';
MATERIALS{14,1,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,9} = 'EMISSIVITY & ABSORPTION:  0.95  2.14';
MATERIALS{16,1,9} = ' ';

MATERIALS{17,1,9} = 'COMPONENT:       POM_inter';
MATERIALS{18,1,9} = 'STATE:           S';
MATERIALS{19,1,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{20,1,9} = 'HEAT CAPACITY:   1649 1.15  0  0';
MATERIALS{21,1,9} = 'CONDUCTIVITY:    0.19  -0.00006  0  0';
MATERIALS{22,1,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,9} = 'EMISSIVITY & ABSORPTION:  0.95  2.14';
MATERIALS{24,1,9} = ' ';

MATERIALS{25,1,9} = 'COMPONENT:       POM_ch';
MATERIALS{26,1,9} = 'STATE:           S';
MATERIALS{27,1,9} = 'DENSITY:         265  0  0  0';
MATERIALS{28,1,9} = 'HEAT CAPACITY:   1250  0  0  0';
MATERIALS{29,1,9} = 'CONDUCTIVITY:    0.5  0  0  0';
MATERIALS{30,1,9} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{31,1,9} = 'EMISSIVITY & ABSORPTION:  0.95  10000';
MATERIALS{32,1,9} = ' ';

MATERIALS{33,1,9} = 'COMPONENT:       POM_g1';
MATERIALS{34,1,9} = 'STATE:           G';
MATERIALS{35,1,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{36,1,9} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{37,1,9} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{38,1,9} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{39,1,9} = 'EMISSIVITY & ABSORPTION:  1  2.14';
MATERIALS{40,1,9} = ' ';

MATERIALS{41,1,9} = 'COMPONENT:       POM_g2';
MATERIALS{42,1,9} = 'STATE:           G';
MATERIALS{43,1,9} = 'DENSITY:         1424  0  0  0';
MATERIALS{44,1,9} = 'HEAT CAPACITY:   1880  0  0  0';
MATERIALS{45,1,9} = 'CONDUCTIVITY:    0.25  0  0  0';
MATERIALS{46,1,9} = 'TRANSPORT:       1e-5  0  0  0';
MATERIALS{47,1,9} = 'EMISSIVITY & ABSORPTION:  1  2.14';
MATERIALS{48,1,9} = ' ';

MATERIALS{1,2,9} = 'REACTION:       POM + NOCOMP -> POM_melt + POM_g1';
MATERIALS{2,2,9} = 'STOICHIOMETRY:  1    0         1    0';
MATERIALS{3,2,9} = 'ARRHENIUS:      2.69e42  382000';
MATERIALS{4,2,9} = 'HEAT:           -192100  0  0  0';
MATERIALS{5,2,9} = 'TEMP LIMIT:     L  300';
MATERIALS{6,2,9} = ' ';

MATERIALS{7,2,9} = 'REACTION:       POM_melt + NOCOMP -> POM_inter + POM_g1';
MATERIALS{8,2,9} = 'STOICHIOMETRY:  1    0         0.4    0.6';
MATERIALS{9,2,9} = 'ARRHENIUS:      3.835e14  200000';
MATERIALS{10,2,9} = 'HEAT:           -1192000  0  0  0';
MATERIALS{11,2,9} = 'TEMP LIMIT:     L  300';
MATERIALS{12,2,9} = ' ';

MATERIALS{13,2,9} = 'REACTION:       POM_inter + NOCOMP -> POM_ch + POM_g2';
MATERIALS{14,2,9} = 'STOICHIOMETRY:  1    0         0    1';
MATERIALS{15,2,9} = 'ARRHENIUS:       4.758378e44  590000';
MATERIALS{16,2,9} = 'HEAT:           -1352000  0  0  0';
MATERIALS{17,2,9} = 'TEMP LIMIT:     L  300';
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

MATERIALS{9,1,10} = 'COMPONENT:       ABS_glass';
MATERIALS{10,1,10} = 'STATE:           S';
MATERIALS{11,1,10} = 'DENSITY:         1050  0  0  0';
MATERIALS{12,1,10} = 'HEAT CAPACITY:   1579.5  1.26  0  0';
MATERIALS{13,1,10} = 'CONDUCTIVITY:    0.21  -0.00026  0  0';
MATERIALS{14,1,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{15,1,10} = 'EMISSIVITY & ABSORPTION:  0.95  1.71';
MATERIALS{16,1,10} = ' ';

MATERIALS{17,1,10} = 'COMPONENT:       ABS_ch';
MATERIALS{18,1,10} = 'STATE:           S';
MATERIALS{19,1,10} = 'DENSITY:         80  0  0  0';
MATERIALS{20,1,10} = 'HEAT CAPACITY:   820  0.112  0  0';
MATERIALS{21,1,10} = 'CONDUCTIVITY:    0.13  -5.4e-4  4.8e-9  3';
MATERIALS{22,1,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{23,1,10} = 'EMISSIVITY & ABSORPTION:  0.86  31.25';
MATERIALS{24,1,10} = ' ';

MATERIALS{25,1,10} = 'COMPONENT:       ABS_g';
MATERIALS{26,1,10} = 'STATE:           G';
MATERIALS{27,1,10} = 'DENSITY:         1050  0  0  0';
MATERIALS{28,1,10} = 'HEAT CAPACITY:   1800  0  0  0';
MATERIALS{29,1,10} = 'CONDUCTIVITY:    0.30  -0.00028  0  0';
MATERIALS{30,1,10} = 'TRANSPORT:       2e-5  0  0  0';
MATERIALS{31,1,10} = 'EMISSIVITY & ABSORPTION:  0.95  1.71';
MATERIALS{32,1,10} = ' ';

MATERIALS{1,2,10} = 'REACTION:       ABS + NOCOMP -> ABS_ch + ABS_g';
MATERIALS{2,2,10} = 'STOICHIOMETRY:  1    0         0.023    0.977';
MATERIALS{3,2,10} = 'ARRHENIUS:      9.995e13  218500';
MATERIALS{4,2,10} = 'HEAT:           -460000  0  0  0';
MATERIALS{5,2,10} = 'TEMP LIMIT:     L  300';
%% 
%% MIXTURES

s1 = get(handles.swelling_s,'String');
l1 = get(handles.swelling_l,'String');
g1 = get(handles.swelling_g,'String');
cond1 = get(handles.par_cond,'String');
trans1 = get(handles.par_trans,'String');


MATERIALS{1,1,11} = ' ';
MATERIALS{2,1,11} = 'MIXTURES';
MATERIALS{3,1,11} = sprintf('S SWELLING:           %s',s1);
MATERIALS{4,1,11} = sprintf('L SWELLING:           %s',l1);
MATERIALS{5,1,11} = sprintf('G SWELLING LIMIT:     %s',g1); %1e-30';
MATERIALS{6,1,11} = sprintf('PARALL CONDUCTIVITY:  %s',cond1);
MATERIALS{7,1,11} = sprintf('PARALL TRANSPORT:     %s',trans1); %0.5';

%%
index_selected = get(handles.cmp_list,'Value');
NI = size(index_selected,2);
Matl_index=[10, 2, 6, 4, 1, 5, 7, 8, 3, 9];

for j = 1:NI %Thermodynamics
   a{j}=char(MATERIALS{:,1,Matl_index(index_selected(j))});
end

b=char(MATERIALS{:,1,11}); %Mixtures
b(all(b == ' ', 2),:) = [];

for j = 1:NI %Kinematics 
    c{j}=char(MATERIALS{:,2,Matl_index(index_selected(j))});
end

X = char(a);
X(all(X == ' ', 2),:) = [];
Z = char(c);
Z(all(Z == ' ', 2),:) = [];
Y = char(X,[ ],b,[ ],Z);

[FileName,PathName] = uiputfile('*.cmp','Save as');
dlmwrite(FileName,Y,'delimiter', '', 'newline', 'pc');
movefile(FileName,PathName,'f');
    
function swelling_s_Callback(hObject, eventdata, handles)
get(hObject,'String');

function swelling_s_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function swelling_l_Callback(hObject, eventdata, handles)
get(hObject,'String');

function swelling_l_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function swelling_g_Callback(hObject, eventdata, handles)
get(hObject,'String');

function swelling_g_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function par_cond_Callback(hObject, eventdata, handles)
get(hObject,'String');

function par_cond_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function par_trans_Callback(hObject, eventdata, handles)
get(hObject,'String');

function par_trans_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end