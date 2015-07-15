function varargout = Layers_1D(varargin)
% LAYERS_1D MATLAB code for Layers_1D.fig
%      LAYERS_1D, by itself, creates a new LAYERS_1D or raises the existing
%      singleton*.
%
%      H = LAYERS_1D returns the handle to a new LAYERS_1D or the handle to
%      the existing singleton*.
%
%      LAYERS_1D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAYopoeERS_1D.M with the given input arguments.
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

% Last Modified by GUIDE v2.5 08-Jul-2015 18:06:02

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
handles.output = hObject;
guidata(hObject, handles);

fdd = fopen('test.cmp'); %open file
file_strings = textscan(fdd, '%s', 'Delimiter', ':'); %scan file and make new line after ':'
fclose(fdd); % close file

file_strings_sz = size(file_strings{1}); %size of file_strings (number of rows)
file_strings_ix = 0; %counter for amount of lines
cmp_ix = 0; %counter for amount of components
state_ix = 0;
while file_strings_ix < file_strings_sz(1,1) %while the counter is less than the actual amount of lines in file continue loop
    file_strings_ix = file_strings_ix+1; % add 1 to the counter to identify what line it is on
    if strcmp(file_strings{1}{file_strings_ix},'COMPONENT') % if loop reaches string 'COMPONENT'...
        file_strings_ix = file_strings_ix+1; %add 1 to line counter
        cmp_ix=(cmp_ix)+1;
        cmp(cmp_ix,1) = cellstr(file_strings{1}{file_strings_ix});
        file_strings_ix = file_strings_ix+1;
    end
%     if strcmp(file_strings{1}{file_strings_ix},'STATE') % if loop reaches string 'COMPONENT'...
%         file_strings_ix = file_strings_ix+1; %add 1 to line counter
%         state_ix=(state_ix)+1;
%         state(state_ix,1) = cellstr(file_strings{1}{file_strings_ix});
%         file_strings_ix = file_strings_ix+1;
%     end
end
% 
% cmp_val = find(strncmp(state,'G',3));
% index_value = size(cmp_val,1);
% for j = 1:index_value
%     cmp_g(j,1) = cmp(cmp_val(j));
% end
set(handles.mass_frac1_1_1, 'String', cmp)

addlistener(handles.slider1,'Value','PreSet',...
    @(hObject, eventdata)slider1_Callback(hObject, eventdata, handles)); %Makes scrollbar update immediately

movegui(handles.figure1,[0,-.00000001]);

uicontrol('Tag',sprintf('CounterETC'),'String','1','Style','text','Visible','on'); %Initially create a counter for first layer.
%Visibility on for testing. Makes tag CounterETC -> (sprintf('Counter%d',int32(uicontrol_ix)))


function varargout = Layers_1D_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function add_layer_Callback(hObject, eventdata, handles)
% warning('off','MATLAB:hg:uicontrol:MinMustBeLessThanMax')

uicontrol_ix = str2double(get(handles.CounterB,'String'));
uicontrol_xi = str2double(get(findobj('Tag','CounterETC'),'String'));%calls value from counter
if lt(uicontrol_ix,10) %if the counter is less than 10
    
%     positiony = -125 * uicontrol_ix; %multiply to increase the position avoids overlapping
%     if ge(uicontrol_ix,2) %if more than two layers
%     positiony = get(findobj('Tag',(sprintf('uipanel2_%d',int32(uicontrol_ix)))),'Position');
%     positiony = positiony(4);
% %      positiony = -(positiony+5);
%     elseif lt(uicontrol_ix,2) && gt(uicontrol_ix,0) %if less than or equal to 
%     positiony = get(handles.uipanel2_1,'Position');
%     positiony = positiony(4);
%     end
    
    positiony = get(findobj('Tag',(sprintf('uipanel2_%d',int32(uicontrol_ix)))),'Position'); %names the positions of the panel to positiony
    positiony = positiony(4); %gets the length of the panel (positiony)
    
    %% creates listbox and textbox for mass transport
    h = uipanel('Parent',handles.uipanel1,'Tag',sprintf('uipanel2_%d',int32(uicontrol_ix)),'Units','pixels',...
        'Position',(get(handles.uipanel2_1,'Position'))+[0 -positiony 0 0],...
        'Title',sprintf('Layer #%d',int32(uicontrol_ix)+1),'Visible','on',...
        'FontSize',12.0,'FontWeight','bold','TitlePosition','centertop');
    
    uicontrol('Parent',h,'Style',get(handles.text2_1,'Style'),...
        'String',(get(handles.text2_1,'String')),'Units','pixels',...
        'Position',(get(handles.text2_1,'Position')),...
        'Tag',sprintf('text2_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',h,'Style',get(handles.Thick_1,'Style'),...
        'String',(get(handles.Thick_1,'String')),'Units','pixels',...
        'Position',get(handles.Thick_1,'Position'),...
        'Tag',sprintf('Thick_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',h,'Style',get(handles.text3_1,'Style'),...
        'String',(get(handles.text3_1,'String')),'Units','pixels',...
        'Position',(get(handles.text3_1,'Position')),...
        'Tag',sprintf('text3_%d',int32(uicontrol_ix)),'Visible','on');
    
    uicontrol('Parent',h,'Style',get(handles.Temp_1,'Style'),...
        'String',(get(handles.Temp_1,'String')),'Units','pixels',...
        'Position',get(handles.Temp_1,'Position'),...
        'Tag',sprintf('Temp_%d',int32(uicontrol_ix)),'Visible','on');
    
    uicontrol('Parent',h,'Style',get(handles.text4_1,'Style'),...
        'String',(get(handles.text4_1,'String')),'Units','pixels',...
        'Position',(get(handles.text4_1,'Position')),...
        'Tag',sprintf('text4_%d',int32(uicontrol_ix)),'Visible','on');
    
    uicontrol('Parent',h,'Style',get(handles.mass_frac1_1_1,'Style'),...
        'String',get(handles.mass_frac1_1_1,'String'),'Units','pixels','Position',...
        (get(handles.mass_frac1_1_1,'Position')),...
        'Tag',sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',h,'Style',get(handles.mass_frac2_1_1,'Style'),'Units','pixels',...
        'String',get(handles.mass_frac2_1_1,'String'),'Position',(get(handles.mass_frac2_1_1,'Position')),...
        'Tag',sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi)),'Visible','on');
    
    uicontrol('Parent',h,'Style',get(handles.add_mf_1,'Style'),'Units','pixels',...
        'String',get(handles.add_mf_1,'String'),'Position',(get(handles.add_mf_1,'Position')),...
        'Tag',sprintf('add_mf_%d',int32(uicontrol_ix)),'Visible','on');
    
    uicontrol('Parent',h,'Style',get(handles.rem_mf_1,'Style'),'Units','pixels',...
        'String',get(handles.rem_mf_1,'String'),'Position',(get(handles.rem_mf_1,'Position')),...
        'Tag',sprintf('rem_mf_%d',int32(uicontrol_ix)),'Visible','on');
    
    uicontrol('String','1','Units','pixels','Tag',sprintf('Counter%d',int32(uicontrol_ix)),'Visible','off');
    
    %% Position
    % item gets pushed down once inputs are created
    a = 125;
    val_a = [0 a 0 -a];
    val_b = [0 0 0 -a];
    val_c = [0 -a 0 0];
    fp = get(handles.figure1,'Position');
    
    if gt(fp(2),200)
        set(handles.figure1,'Position',(get(handles.figure1,'Position')-(val_a)));
        set(handles.slider1,'Position',(get(handles.slider1,'Position')-(val_b)));
        set(handles.uipanel4,'Position',(get(handles.uipanel4,'Position')-(val_c)));
    end
    
    set(handles.uipanel1,'Position',(get(handles.uipanel1,'Position')-(val_b)));
    set(handles.uipanel2_1,'Position',(get(handles.uipanel2_1,'Position')-(val_c)));
    
%     for j = 1:uicontrol_ix
%         set(findobj('Tag',(sprintf('uipanel2_%d',int32(j))))','Position',...
%             (get(findobj('Tag',(sprintf('uipanel2_%d',int32(j))))','Position')-(val_c)));
%     end

    uicontrol_ix = uicontrol_ix+1;
    if gt(uicontrol_ix,1)
        set(handles.remove_layer,'Visible','On');
    elseif uicontrol_ix == 1
        set(handles.remove_layer,'Visible','Off');
    end
    
    set(handles.uipanel1,'Units','normalized');
    posy = get(handles.uipanel1,'Position');
    set(handles.slider1,'Max',posy(4)-.97);
    set(handles.uipanel1,'Units','pixels');
   
    warning('off','MATLAB:hg:uicontrol:MinMustBeLessThanMax')
    
    set(handles.CounterB,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterB,'String')))+1)))); %add 1 to counter
end

function remove_layer_Callback(hObject, eventdata, handles)
warning('off','MATLAB:hg:uicontrol:MinMustBeLessThanMax')

set(handles.CounterB,'String',...
    (sprintf('%d',int32((str2double(get(handles.CounterB,'String')))-1))));
uicontrol_ix = str2double(get(handles.CounterB,'String'));
uicontrol_xi = str2double(get(findobj('Tag','CounterETC'),'String'));

delete(findobj('Tag',(sprintf('text2_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('Thick_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('text3_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('Temp_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('text4_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi)))));
delete(findobj('Tag',(sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi)))));
delete(findobj('Tag',(sprintf('add_mf_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('rem_mf_%d',int32(uicontrol_ix)))));
delete(findobj('Tag',(sprintf('uipanel2_%d',int32(uicontrol_ix)))));

a = -125;
val_a = [0 a 0 -a];
val_b = [0 0 0 -a];
val_c = [0 -a 0 0];

up = get(handles.uipanel1,'Position');
fp = get(handles.figure1,'Position');

if le(up(4),fp(4))
    set(handles.figure1,'Position',(get(handles.figure1,'Position')-(val_a)));
    set(handles.slider1,'Position',(get(handles.slider1,'Position')-(val_b)));
    set(handles.uipanel4,'Position',(get(handles.uipanel4,'Position')-(val_c)));
end

set(handles.uipanel1,'Position',(get(handles.uipanel1,'Position')-(val_b)));
set(handles.uipanel2_1,'Position',(get(handles.uipanel2_1,'Position')-(val_c)));

for j = 1:(uicontrol_ix-1)
    set(findobj('Tag',(sprintf('uipanel2_%d',int32(j))))','Position',...
        (get(findobj('Tag',(sprintf('uipanel2_%d',int32(j))))','Position')-(val_c)));
end

if gt(uicontrol_ix,1)
    set(handles.remove_layer,'Visible','On');
elseif uicontrol_ix == 1
    set(handles.remove_layer,'Visible','Off');
end

set(handles.uipanel1,'Units','normalized');
posy = get(handles.uipanel1,'Position');
set(handles.slider1,'Max',posy(4)-.97);
set(handles.uipanel1,'Units','pixels');

function mass_frac1_1_1_Callback(hObject, eventdata, handles)

function mass_frac2_1_1_Callback(hObject, eventdata, handles)

function Thick_1_Callback(hObject, eventdata, handles)

function Temp_1_Callback(hObject, eventdata, handles)

function layer_create_Callback(hObject, eventdata, handles)

function slider1_Callback(hObject, eventdata, handles)
set(handles.uipanel1,'Units','normalized');
posy = get(handles.uipanel1,'Position');
set(handles.slider1,'Max',posy(4)-.97);
set(handles.uipanel1,'Units','pixels');
set(handles.uipanel1,'Units','normalized');
gpos = get(handles.uipanel1,'Position');
sval = get(handles.slider1,'Value');
gpos(1,2)= (-sval);
display(gpos);
set(handles.uipanel1,'Position',gpos);
set(handles.uipanel1,'Units','pixels');

function add_mf_1_Callback(hObject, eventdata, handles) %creates the mass fraction box
% uicontrol_xi = str2double(get(handles.CounterX,'String'));%CounterX is number of mass fraction box displayed
uicontrol_xi = str2double(get(findobj('Tag','CounterETC'),'String'));%CounterETC = number of mass fraction box available depending on layer #
uicontrol_ix = str2double(get(handles.CounterB,'String'));

if lt(uicontrol_xi,size(get(handles.mass_frac1_1_1,'String'),1))
    
    set(findobj('Tag','CounterETC'),'String',...
        (sprintf('%d',int32((str2double(get(findobj('Tag','CounterETC'),'String')))+1)))); %adds one to CounterX
    positiony = -24 * (uicontrol_xi);
    
    a = 24;
    val_a = [0 -a 0 a]; %moves object down 'a' pixels and increase height by 'a' pixels
    val_b = [0 0 0 a]; %increase height by 'a' pixels
    val_c = [0 a 0 0]; %moves object up 'a' pixels
    
    %Increase size of object.
    set(handles.uipanel2_1,'Position',(get(handles.uipanel2_1,'Position'))+val_b);
    set(handles.uipanel1,'Position',(get(handles.uipanel1,'Position'))+val_b);
    
    %Depending if object 
    fp = get(handles.figure1,'Position');
    if gt(fp(2),100)
        set(handles.figure1,'Position',(get(handles.figure1,'Position')+(val_a)));
        set(handles.slider1,'Position',(get(handles.slider1,'Position')+(val_b)));
        set(handles.uipanel4,'Position',(get(handles.uipanel4,'Position')+(val_c)));
    end
    
    %Moves object stated below up.
%     set(handles.text2_1,'Position', (get(handles.text2_1,'Position')+(val_c)));
%     set(handles.Thick_1,'Position', (get(handles.Thick_1,'Position')+(val_c)));
%     set(handles.text3_1,'Position', (get(handles.text3_1,'Position')+(val_c)));
%     set(handles.Temp_1,'Position', (get(handles.Temp_1,'Position')+(val_c)));
%     set(handles.text4_1,'Position', (get(handles.text4_1,'Position')+(val_c)));
%     set(handles.mass_frac1_1_1,'Position', (get(handles.mass_frac1_1_1,'Position')+(val_c)));
%     set(handles.mass_frac2_1_1,'Position', (get(handles.mass_frac2_1_1,'Position')+(val_c)));
    
    text2 = findobj('Tag',(sprintf('text2_%d',int32(uicontrol_ix))));
    Thick = findobj('Tag',(sprintf('Thick_%d',int32(uicontrol_ix))));
    text3 = findobj('Tag',(sprintf('text3_%d',int32(uicontrol_ix))));
    text4 = findobj('Tag',(sprintf('text4_%d',int32(uicontrol_ix))));
    Temp = findobj('Tag',(sprintf('Temp_%d',int32(uicontrol_ix))));
    
    set(text2,'Position', (get(text2)+(val_c)));
    set(Thick,'Position', (get(Thick,'Position')+(val_c)));
    set(text3,'Position', (get(text3,'Position')+(val_c)));
    set(Temp,'Position', (get(Temp,'Position')+(val_c)));
    set(text4,'Position', (get(handles.text4_1,'Position')+(val_c)));
    
    for j = 1:(uicontrol_xi) %loop which shifts programatically made interface
        massfrac1 = findobj('Tag',(sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(j))));
        massfrac2 = findobj('Tag',(sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(j))));
        pmf1=get(massfrac1,'Position');
        pmf2 =get(massfrac2,'Position');
        celldisp(pmf1);
        celldisp(pmf2);
        set(massfrac1,'Position',(pmf1+(val_c)));
        set(massfrac2,'Position',(pmf2+(val_c)));
    end
    
    uicontrol('Parent',handles.uipanel2_1,'Style','popup',... %Creates mass fraction options 
        'String',(get(handles.mass_frac1_1_1,'String')),...
        'Position',(get(handles.mass_frac1_1_1,'Position'))+[0 positiony 0 0],...
        'Tag',(sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi))),'Visible','on');
    
    uicontrol('Parent',handles.uipanel2_1,'Style','edit',...
        'String','0','Position',(get(handles.mass_frac2_1_1,'Position'))+[0 positiony 0 0],...
        'Tag',(sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi))),'Visible','on'...
        ,'String',(sprintf('%d',int32(uicontrol_xi))));
    
    elseif gt(uicontrol_ix,1) && lt(uicontrol_xi,size(get(handles.mass_frac1_1_1,'String'),1))
    %Something is supposed to happen. Figure it out.
end
    set(handles.uipanel1,'Units','normalized');
    posy = get(handles.uipanel1,'Position');
    set(handles.slider1,'Max',posy(4)-.97);
    set(handles.uipanel1,'Units','pixels');

function rem_mf_1_Callback(hObject, eventdata, handles) %removes the mass fraction box %STILL IN DEVELOPMENT
% uicontrol_xi = str2double(get(handles.CounterX,'String'));
uicontrol_xi = str2double(get(findobj('Tag','CounterETC'),'String'));
uicontrol_ix = str2double(get(handles.CounterB,'String'));

if gt(uicontrol_xi,1)
    set(findobj('Tag','CounterETC'),'String',...
        (sprintf('%d',(int32(str2double(get(findobj('Tag','CounterETC'),'String')))-1))));
    
    % figure out if add or subtract one later or after
    mass_frac1 = findobj('Tag',(sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi))));
    mass_frac2 = findobj('Tag',(sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(uicontrol_xi))));
    
    delete(mass_frac1);
    delete(mass_frac2);
    
    a = 24;
    val_a = [0 a 0 -a];
    val_b = [0 0 0 -a];
    val_c = [0 -a 0 0];
    set(handles.uipanel2_1,'Position',(get(handles.uipanel2_1,'Position'))+val_b);
    set(handles.uipanel1,'Position',(get(handles.uipanel1,'Position'))+val_b);
    
    up = get(handles.uipanel1,'Position');
    fp = get(handles.figure1,'Position');
    
    if le(up(4),fp(4))
        set(handles.uipanel4,'Position',(get(handles.uipanel4,'Position'))+val_c);
        set(handles.figure1,'Position',(get(handles.figure1,'Position'))+val_a);
        set(handles.slider1,'Position',(get(handles.slider1,'Position'))+val_b);
    end
    
    text2 = findobj('Tag',(sprintf('text2_%d',int32(uicontrol_ix))));
    Thick = findobj('Tag',(sprintf('Thick_%d',int32(uicontrol_ix))));
    text3 = findobj('Tag',(sprintf('text3_%d',int32(uicontrol_ix))));
    text4 = findobj('Tag',(sprintf('text4_%d',int32(uicontrol_ix))));
    Temp = findobj('Tag',(sprintf('Temp_%d',int32(uicontrol_ix))));
    
    set(text2,'Position', (get(text2)+(val_c)));
    set(Thick,'Position', (get(Thick,'Position')+(val_c)));
    set(text3_,'Position', (get(text3,'Position')+(val_c)));
    set(Temp,'Position', (get(Temp,'Position')+(val_c)));
    set(text4,'Position', (get(handles.text4_1,'Position')+(val_c)));
    set(mass_frac1,'Position', (get(mass_frac1,'Position')+(val_c)));
    set(mass_frac2,'Position', (get(mass_frac2,'Position')+(val_c)));
    
    for j = 2:(uicontrol_xi-1) %loop which shifts programatically made interface
        massfrac1 = findobj('Tag',(sprintf('mass_frac1_%d_%d',int32(uicontrol_ix),int32(j))));
        massfrac2 = findobj('Tag',(sprintf('mass_frac2_%d_%d',int32(uicontrol_ix),int32(j))));
        pmf1=get(massfrac1,'Position')
        pmf2 =get(massfrac2,'Position')
        set(massfrac1,'Position',(pmf1+(val_c)));
        set(massfrac2,'Position',(pmf2+(val_c)));
    end
    
    %Allows for easy shifting and scrolling*
    set(handles.uipanel1,'Units','normalized');
    posy = get(handles.uipanel1,'Position');
    set(handles.slider1,'Max',posy(4)-.97);
    set(handles.uipanel1,'Units','pixels');
end
