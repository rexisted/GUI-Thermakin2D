
function varargout = Cond_1D(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Cond_1D_OpeningFcn, ...
    'gui_OutputFcn',  @Cond_1D_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function Cond_1D_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

[FileName,PathName] = uigetfile({'*.cmp',...
    'Component Files (*.cmp)';'*.txt', 'Text Files (*.txt)';...
    '*.*','All Files (*.*)'},'Select the Components File'); %add default path
pathn = fullfile(PathName,FileName);
curpath = fullfile(pwd,FileName);
if isequal(FileName,0) %if no file is chosen or canceled then display Cancel
    disp('User selected Cancel')
else % else continue
    disp(['User selected ', fullfile(PathName, FileName)])
    if isequal(curpath,pathn) % determine if file is in current directory or not
        fdd = fopen(FileName); %open file
        file_strings = textscan(fdd, '%s', 'Delimiter', ':'); %scan file and make new line after ':'
        fclose(fdd); % close file
    else
        copyfile(fullfile(PathName, FileName)); % copy file into directory for Matlab
        fdd = fopen(FileName);
        file_strings = textscan(fdd, '%s', 'Delimiter', ':');
        fclose(fdd);
        delete(FileName); % delete file
    end
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
        if strcmp(file_strings{1}{file_strings_ix},'STATE') % if loop reaches string 'COMPONENT'...
            file_strings_ix = file_strings_ix+1; %add 1 to line counter
            state_ix=(state_ix)+1;
            state(state_ix,1) = cellstr(file_strings{1}{file_strings_ix});
            file_strings_ix = file_strings_ix+1;
        end
    end
    
    cmp_val = find(strncmp(state,'G',3));
    index_value = size(cmp_val,1);
    for j = 1:index_value
        cmp_2(j,1) = cmp(cmp_val(j));
    end
    
    set(handles.top_masstrans_2, 'String', cmp_2)
    set(handles.bot_masstrans_2, 'String', cmp_2)
    set(handles.top_igntmassflux_1, 'String', cmp_2)
    set(handles.bot_igntmassflux_1, 'String', cmp_2)
end

bot = get(handles.bot_rad,'Position');
bot = bot(2);
bot_1 = get(handles.bot_flame,'Position');
bot_1 = bot_1(2);
if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
    set(handles.bb_slider,'Visible','on');
elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
    set(handles.bb_slider,'Visible','off');
end

top = get(handles.top_rad,'Position');
top = top(2);
top_1 = get(handles.top_flame,'Position');
top_1 = top_1(2);
if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0)
    set(handles.tb_slider,'Visible','on');
elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0)
    set(handles.tb_slider,'Visible','off');
end

% --- Outputs from this function are returned to the command line.
function varargout = Cond_1D_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

function create_cnd_Callback(hObject, eventdata, handles)

%% bottom
%popup selections
bm1 = get(handles.bot_masstrans_1,'Value');
if bm1 == 1
    bot_masstrans_1 = 'YES';
elseif bm1 == 2
    bot_masstrans_1 = 'NO';
end

bm2 = get(handles.bot_masstrans_2,'Value');
bot_masstrans_2 = get(handles.bot_masstrans_2,'String');
bot_masstrans_2 = bot_masstrans_2{bm2};

bm3 = get(handles.bot_masstrans_3,'Value'); %Test this to minimize code
if bm3 == 1;
    bot_masstrans_3 = 'EXP';
elseif bm3 == 2;
    bot_masstrans_3 = 'LIN';
end

be = get(handles.bot_extrad,'Value'); %consider YES/NO (conserves space) or yes/no (change nothing)
if be == 1
    bot_extrad = 'YES';
elseif be == 2
    bot_extrad = 'NO';
end

bf = get(handles.bot_flame,'Value'); %consider YES/NO (conserves space) or yes/no (change nothing)
if bf == 1
    bot_flame = 'YES';
elseif bf == 2
    bot_flame = 'NO';
end

br = get(handles.bot_repeat,'Value'); %consider YES/NO (conserves space) or yes/no (change nothing)
if br == 1
    bot_repeat = 'YES';
elseif br == 2
    bot_repeat = 'NO';
end

bot_igntmassflux_1 = get(handles.bot_igntmassflux_1,'String');
bot_igntmassflux_1 = bot_igntmassflux_1{get(handles.bot_igntmassflux_1,'Value')};

ba = get(handles.bot_absorpmode,'Value'); %Test this to minimize code
if ba == 1;
    bot_absorpmode = 'RAND';
elseif ba == 2;
    bot_absorpmode = 'MAX';
end
%% top
%input strings
top_convcoeff_1 = get(handles.top_convcoeff_1,'String');
top_outtemptime_1 = get(handles.top_outtemptime_1,'String');
top_outtemptime_2 = get(handles.top_outtemptime_2,'String');
top_time1_1 = get(handles.top_time1_1,'String');
top_time1_2 = get(handles.top_time1_2,'String');
top_time1_3 = get(handles.top_time1_3,'String');
top_time2_1 = get(handles.top_time2_1,'String');
top_time2_2 = get(handles.top_time2_2,'String');
top_time2_3 = get(handles.top_time2_3,'String');
top_outtemp = get(handles.top_outtemp,'String');
top_convcoeff_2 = get(handles.top_convcoeff_2,'String');
top_rad = get(handles.top_rad,'String');
top_masstrans_4 = get(handles.top_masstrans_4,'String');
top_masstrans_5 = get(handles.top_masstrans_5,'String');
top_igntmassflux_2 = get(handles.top_igntmassflux_2,'String');

%popup selections
tm1 = get(handles.top_masstrans_1,'Value');
if tm1 == 1
    top_masstrans_1 = 'YES';
elseif tm1 == 2
    top_masstrans_1 = 'NO';
end

tm2 = get(handles.top_masstrans_2,'Value');
top_masstrans_2 = get(handles.top_masstrans_2,'String');
top_masstrans_2 = top_masstrans_2{tm2};

tm3 = get(handles.top_masstrans_3,'Value');
if tm3 == 1;
    top_masstrans_3 = 'EXP';
elseif tm3 == 2;
    top_masstrans_3 = 'LIN';
end

te = get(handles.top_extrad,'Value');
if te == 1
    top_extrad = 'YES';
elseif te == 2
    top_extrad = 'NO';
end

tf = get(handles.top_flame,'Value');
if tf == 1
    top_flame = 'YES';
elseif tf == 2
    top_flame = 'NO';
end

tr = get(handles.top_repeat,'Value');
if tr == 1
    top_repeat = 'YES';
elseif tr == 2
    top_repeat = 'NO';
end

ti1 = get(handles.top_igntmassflux_1,'Value');
top_igntmassflux_1 = get(handles.top_igntmassflux_1,'String');
top_igntmassflux_1 = top_igntmassflux_1{ti1};

ta = get(handles.top_absorpmode,'Value');
if ta == 1;
    top_absorpmode = 'RAND';
elseif ta == 2;
    top_absorpmode = 'MAX';
end

%added popup selections

%FIX FIX

%% OB

obj_bound{1,1} = 'OBJECT BOUNDARIES';
obj_bound{2,1} = '*****************';
obj_bound{3,1} = ' ';
%% TOP BOUNDARY
obj_bound{4,1} = 'TOP BOUNDARY';
obj_bound{5,1} = ' ';
obj_bound{6,1} = sprintf('MASS TRANSPORT:  %s',top_masstrans_1); %YES';

uicontrol_3 = str2double(get(handles.CounterD,'String'));
uicontrol_4 = str2double(get(handles.CounterE,'String'));
x = uicontrol_3-1+7;%number should be set as how many components being used in mass transport and igntmassflux
y = uicontrol_4-1;

if tm1 == 1;
    obj_bound{7,1} = sprintf('%s  %s  %s  %s',top_masstrans_2,top_masstrans_3,top_masstrans_4,top_masstrans_5);
    for j = 2:uicontrol_3
        tmm2 = get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','String');
        tmm2_ix = get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Value');
        tmm2 = tmm2{tmm2_ix};
        
        tmm3 = get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','String');
        tmm3_ix = get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Value');
        tmm3 = tmm3{tmm3_ix};
        
        tmm4 = get(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','String');
        tmm5 = get(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','String');
        
        obj_bound{j+6,1} = sprintf('%s  %s  %s  %s',tmm2,tmm3,tmm4,tmm5);
    end
elseif tm1 == 2;
    obj_bound{7:x,1} = '';
    
    %     MT = obj_bound{7:x,1};
    obj_bound{7:x,1}(all(obj_bound{7:x,1} == ' ', 2),:) = [];
end

obj_bound{x+1,1} = ' ';

obj_bound{x+2,1} = sprintf('OUTSIDE TEMP TIME PROG:  %s  %s',top_outtemptime_1,top_outtemptime_2);
obj_bound{x+3,1} = sprintf('CONVECTION COEFF:  %s',top_convcoeff_1);

obj_bound{x+4,1} = ' ';

obj_bound{x+5,1} = sprintf('EXTERNAL RADIATION:  %s',top_extrad);
if te == 1;
    obj_bound{x+6,1} = sprintf('TIME PROG1:  %s  %s  %s',top_time1_1,top_time1_2,top_time1_3);
    obj_bound{x+7,1} = sprintf('TIME PROG2:  %s  %s  %s',top_time2_1,top_time2_2,top_time2_3);
    obj_bound{x+8,1} = sprintf('REPEAT:  %s',top_repeat);
    obj_bound{x+9,1} = sprintf('ABSORPTION MODE:  %s',top_absorpmode);
elseif te == 2;
    obj_bound{x+6,1} = '';
    obj_bound{x+7,1} = '';
    obj_bound{x+8,1} = '';
    obj_bound{x+9,1} = '';
    
    % EX = obj_bound{x+5:x+8,1};
    obj_bound{x+6:x+8,1}(all(obj_bound{x+5:x+8,1} == ' ', 2),:) = [];
end

obj_bound{x+10,1} = ' ';

obj_bound{x+11,1} = sprintf('FLAME:  %s',top_flame);
xy = x+y;
if tf == 1;
    obj_bound{x+12,1} = 'IGNITION MASS FLUXES:';
    obj_bound{x+13,1} = sprintf('%s  %s',top_igntmassflux_1,top_igntmassflux_2);
    
    for j = 2:uicontrol_4
        timf1 = get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','String');
        timf1_ix = get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Value');
        timf1 = timf1{timf1_ix};
        
        timf2 = get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','String');
        obj_bound{j-1+x+13,1} = sprintf('%s  %s',timf1,timf2);
    end
    
    obj_bound{xy+15,1} = sprintf('OUTSIDE TEMP:  %s',top_outtemp);
    obj_bound{xy+16,1} = sprintf('CONVECTION COEFF:  %s',top_convcoeff_2);
    obj_bound{xy+17,1} = sprintf('RADIATION:  %s',top_rad);
elseif tf == 2;
    obj_bound{x+12,1} = '';
    obj_bound{x+13:xy+13,1} = '';
    obj_bound{xy+14,1} = '';
    obj_bound{xy+15,1} = '';
    obj_bound{xy+16,1} = '';
    
    %     IMF = obj_bound{x+12:xy+16};
    obj_bound{x+12:xy+16,1}(all(obj_bound{x+12:xy+16,1} == ' ', 2),:) = [];
end
obj_bound{xy+17,1} = ' ';
%% BOTTOM BOUNDARY
uicontrol_1 = str2double(get(handles.CounterB,'String'));
uicontrol_2 = str2double(get(handles.CounterC,'String'));
z = uicontrol_1-1;
w = uicontrol_2-1;

obj_bound{xy+18,1} = 'BOTTOM BOUNDARY';
obj_bound{xy+19,1} = ' ';

obj_bound{xy+20,1} = sprintf('MASS TRANSPORT:  %s',bot_masstrans_1);
xyz = xy+z;
if bm1 == 1;
    obj_bound{xy+21,1} = sprintf('%s  %s  %s  %s',bot_masstrans_2,bot_masstrans_3,...
        get(handles.bot_masstrans_4,'String'),get(handles.bot_masstrans_5,'String'));
    
    for j = 2:uicontrol_1
        bmm2 = get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','String');
        bmm2_ix = get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Value');
        bmm2 = bmm2{bmm2_ix};
        
        bmm3 = get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','String');
        bmm3_ix = get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Value');
        bmm3 = bmm3{bmm3_ix};
        
        bmm4 = get(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','String');
        bmm5 = get(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','String');
        obj_bound{j-1+xy+21,1} = sprintf('%s  %s  %s  %s',bmm2,bmm3,bmm4,bmm5);
    end
    
elseif bm1 == 2;
    obj_bound{xy+21:xyz+21,1} = '';
    
    % BMT = obj_bound{xy+21:xyz+21,1};
    obj_bound{xy+21:xyz+21,1}(all(obj_bound{xy+21:xyz+21,1} == ' ', 2),:) = [];
end



obj_bound{xyz+22,1} = ' ';
obj_bound{xyz+23,1} = sprintf('OUTSIDE TEMP TIME PROG:  %s  %s',...
    get(handles.bot_outtemptime_1,'String'),get(handles.bot_outtemptime_2,'String'));
obj_bound{xyz+24,1} = sprintf('CONVECTION COEFF:  %s',get(handles.bot_convcoeff_1,'String'));
obj_bound{xyz+25,1} = ' ';

obj_bound{xyz+26,1} = sprintf('EXTERNAL RADIATION:  %s',bot_extrad);

if be == 1;
    obj_bound{xyz+27,1} = sprintf('TIME PROG1:  %s  %s  %s',get(handles.bot_time1_1,'String'),...
        get(handles.bot_time1_2,'String'),get(handles.bot_time1_3,'String'));
    obj_bound{xyz+28,1} = sprintf('TIME PROG2:  %s  %s  %s',get(handles.bot_time2_1,'String'),...
        get(handles.bot_time2_2,'String'),get(handles.bot_time2_3,'String'));
    obj_bound{xyz+29,1} = sprintf('REPEAT:  %s',bot_repeat);
    obj_bound{xyz+30,1} = sprintf('ABSORPTION MODE:  %s',bot_absorpmode);
elseif be == 2;
    obj_bound{xyz+27,1} = '';
    obj_bound{xyz+28,1} = '';
    obj_bound{xyz+29,1} = '';
    obj_bound{xyz+30,1} = '';
    
    % BEX = obj_bound{xyz+27:xyz+30,1};
    obj_bound{xyz+27:xyz+30,1}(all(obj_bound{xyz+27:xyz+30,1} == ' ', 2),:) = [];
end

obj_bound{xyz+31,1} = ' ';

obj_bound{xyz+32,1} = sprintf('FLAME:  %s',bot_flame);

xyzw=xyz+w;
if bf == 1;
    obj_bound{xyz+33,1} = 'IGNITION MASS FLUXES:';
    obj_bound{xyz+34,1} = sprintf('%s  %s',bot_igntmassflux_1,...
        get(handles.bot_igntmassflux_2,'String'));
    
    for j = 2:uicontrol_2
        bimf1 = get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','String');
        bimf1_ix = get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Value');
        bimf1 = bimf1{bimf1_ix};
        
        bimf2 = get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','String');
        obj_bound{j-1+xyz+34,1} = sprintf('%s  %s',bimf1,bimf2);
    end
    
    obj_bound{xyzw+36,1} = sprintf('OUTSIDE TEMP:  %s',get(handles.bot_outtemp,'String'));
    obj_bound{xyzw+37,1} = sprintf('CONVECTION COEFF:  %s',get(handles.bot_convcoeff_2,'String'));
    obj_bound{xyzw+38,1} = sprintf('RADIATION:  %s',get(handles.bot_rad,'String'));
elseif bf == 2;
    obj_bound{xyz+33,1} = '';
    obj_bound{xyz+34,1} = '';
    obj_bound{xyz+34:xyzw+34,1} = '';
    obj_bound{xyzw+36,1} = '';
    obj_bound{xyzw+37,1} = '';
    obj_bound{xyzw+38,1} = '';
    
    % BIMF = obj_bound{xyz+33:xyzw+38,1};
    obj_bound{xyz+33:xyzw+38,1}(all(obj_bound{xyz+33:xyzw+38,1} == ' ', 2),:) = [];
end

obj_bound{xyzw+39,1} = ' ';

%% INTEGRATION PARAMETERS

ele_s = get(handles.Elem_size,'String');
time1 =  get(handles.Time_1,'String');
durn = get(handles.dur,'String');
elem = get(handles.elem,'String');
time2 = get(handles.time_2,'String');

INT_PARA{1,1} = 'INTEGRATION PARAMETERS';
INT_PARA{2,1} = '**********************';
INT_PARA{3,1} = ' ';
INT_PARA{4,1} = sprintf('ELEMENT SIZE:  %s',ele_s);
INT_PARA{5,1} = sprintf('TIME STEP:  %s',time1);
INT_PARA{6,1} = sprintf('DURATION:  %s',durn);
INT_PARA{7,1} = ' ';
INT_PARA{7,1} = 'OUTPUT FREQUENCY:';
INT_PARA{8,1} = sprintf('ELEMENTS:  %s',elem);
INT_PARA{9,1} = sprintf('TIME STEPS:  %s',time2);

%% CREATE CND FILE

% O = obj_bound{:,1};
% O(all(O == ' ', 2),:) = [];
F = char(obj_bound{:,1},INT_PARA{:,1});

[FileName,PathName] = uiputfile('*.cnd','Save as');
if isequal(FileName,0) %if no file is chosen or canceled then display Cancel
    disp('User selected Cancel')
else
    dlmwrite(FileName,F,'delimiter', '', 'newline', 'pc');
    movefile(FileName,PathName,'f');
end

%% Integration Parameters======================================================================
function Elem_size_Callback(hObject, eventdata, handles)
get(hObject,'String');

function Time_1_Callback(hObject, eventdata, handles)
get(hObject,'String');

function dur_Callback(hObject, eventdata, handles)
get(hObject,'String');

function elem_Callback(hObject, eventdata, handles)
get(hObject,'String');

function time_2_Callback(hObject, eventdata, handles)
get(hObject,'String');

%% DIMENSION CHANGE====================================================
function Dim_change_Callback(hObject, eventdata, handles) %FIX
items = get(hObject,'String');
index_selected = get(hObject,'Value');
item_selected = items{index_selected};
if index_selected == 2;
    run(Cond_2D);
    set(handles.figure1,'Visible','Off');
    disp(item_selected);
end

function Dim_change_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'1D','2D'});

%% Bottom Boundary ===============================================================================================================================================

%% Text Input-------------------------------------------------------------------------------------------
function bot_rad_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_convcoeff_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_outtemp_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time2_3_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time2_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time2_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time1_3_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time1_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_time1_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_outtemptime_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_outtemptime_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_convcoeff_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_masstrans_5_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_masstrans_4_Callback(hObject, eventdata, handles)
get(hObject,'String');
function bot_igntmassflux_2_Callback(hObject, eventdata, handles)
get(hObject,'String');

%% List Box---------------------------------------------------------------------------------------------
function bot_absorpmode_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'RAND','MAX'});
function bot_masstrans_3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'EXP','LIN'});
function bot_repeat_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});

%---------Visible--
function bot_flame_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterC,'String'));
if get(handles.bot_flame,'Value') == 1 && str2double(get(handles.Counter,'String')) == 1
    
    set(handles.text94,'Visible','on');
    set(handles.bot_igntmassflux_1,'Visible','on');
    set(handles.bot_igntmassflux_2,'Visible','on');
    set(handles.text93,'Visible','on');
    set(handles.bot_outtemp,'Visible','on');
    set(handles.text92,'Visible','on');
    set(handles.bot_convcoeff_2,'Visible','on');
    set(handles.text101,'Visible','on');
    set(handles.bot_rad,'Visible','on');
    set(handles.bot_imf_add,'Visible','on');
    set(handles.bot_imf_rem,'Visible','on');
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Visible','on');
    end
    
    set(handles.Counter,'String','2');
    
elseif get(handles.bot_flame,'Value') == 2 && str2double(get(handles.Counter,'String')) == 2
    set(handles.text94,'Visible','off');
    set(handles.bot_igntmassflux_1,'Visible','off');
    set(handles.bot_igntmassflux_2,'Visible','off');
    set(handles.text93,'Visible','off');
    set(handles.bot_outtemp,'Visible','off');
    set(handles.text92,'Visible','off');
    set(handles.bot_convcoeff_2,'Visible','off');
    set(handles.text101,'Visible','off');
    set(handles.bot_rad,'Visible','off');
    set(handles.bot_imf_add,'Visible','off');
    set(handles.bot_imf_rem,'Visible','off');
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Visible','off');
    end
    
    set(handles.Counter,'String','1');
end

bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
function bot_flame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});

function bot_masstrans_1_Callback(hObject, eventdata, handles)
uicontrol_1 = str2double(get(handles.CounterB,'String'));
uicontrol_2 = str2double(get(handles.CounterC,'String'));
if get(handles.bot_masstrans_1,'Value') == 1 && str2double(get(handles.Counter1,'String')) == 1
    %Sets visibility of the following options a line below depending on selected option
    set(handles.bot_masstrans_2,'Visible','on');
    set(handles.bot_masstrans_3,'Visible','on');
    set(handles.bot_masstrans_4,'Visible','on');
    set(handles.bot_masstrans_5,'Visible','on');
    set(handles.bot_mt_add,'Visible','on');
    set(handles.bot_mt_rem,'Visible','on');
    
    for j = 2:uicontrol_1
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Visible','on');
    end
    
    set(handles.Counter1,'String','2');
    
    %% Move other objects upwards to maintain form.
    val_a = [0 25*uicontrol_1 0 0];
    
    set(handles.text96,'Position',(get(handles.text96,'Position')-(val_a)));
    set(handles.bot_outtemptime_1,'Position', (get(handles.bot_outtemptime_1,'Position')-(val_a)));
    set(handles.bot_outtemptime_2,'Position', (get(handles.bot_outtemptime_2,'Position')-(val_a)));
    set(handles.text95,'Position', (get(handles.text95,'Position')-(val_a)));
    set(handles.bot_convcoeff_1,'Position',(get(handles.bot_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text100,'Position', (get(handles.text100,'Position')-(val_a)));
    set(handles.bot_extrad,'Position', (get(handles.bot_extrad,'Position')-(val_a)));
    set(handles.text99,'Position', (get(handles.text99,'Position')-(val_a)));
    set(handles.bot_time1_1,'Position', (get(handles.bot_time1_1,'Position')-(val_a)));
    set(handles.bot_time1_2,'Position', (get(handles.bot_time1_2,'Position')-(val_a)));
    set(handles.bot_time1_3,'Position', (get(handles.bot_time1_3,'Position')-(val_a)));
    set(handles.text98,'Position', (get(handles.text98,'Position')-(val_a)));
    set(handles.bot_time2_1,'Position', (get(handles.bot_time2_1,'Position')-(val_a)));
    set(handles.bot_time2_2,'Position', (get(handles.bot_time2_2,'Position')-(val_a)));
    set(handles.bot_time2_3,'Position', (get(handles.bot_time2_3,'Position')-(val_a)));
    set(handles.text91,'Position', (get(handles.text91,'Position')-(val_a)));
    set(handles.bot_repeat,'Position', (get(handles.bot_repeat,'Position')-(val_a)));
    set(handles.text90,'Position', (get(handles.text90,'Position')-(val_a)));
    set(handles.bot_absorpmode,'Position', (get(handles.bot_absorpmode,'Position')-(val_a)));
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end

elseif get(handles.bot_masstrans_1,'Value') == 2 && str2double(get(handles.Counter1,'String')) == 2
    %Sets visibility of the following options a line below depending on selected option
    
    set(handles.bot_masstrans_2,'Visible','off');
    set(handles.bot_masstrans_3,'Visible','off');
    set(handles.bot_masstrans_4,'Visible','off');
    set(handles.bot_masstrans_5,'Visible','off');
    set(handles.bot_mt_add,'Visible','off');
    set(handles.bot_mt_rem,'Visible','off');
    
    for j = 2:uicontrol_1
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Visible','off');
    end
    
    set(handles.Counter1,'String','1');
    
    val_a = [0 -25*uicontrol_1 0 0];
    
    set(handles.text96,'Position',(get(handles.text96,'Position')-(val_a)));
    set(handles.bot_outtemptime_1,'Position', (get(handles.bot_outtemptime_1,'Position')-(val_a)));
    set(handles.bot_outtemptime_2,'Position', (get(handles.bot_outtemptime_2,'Position')-(val_a)));
    set(handles.text95,'Position', (get(handles.text95,'Position')-(val_a)));
    set(handles.bot_convcoeff_1,'Position',(get(handles.bot_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text100,'Position', (get(handles.text100,'Position')-(val_a)));
    set(handles.bot_extrad,'Position', (get(handles.bot_extrad,'Position')-(val_a)));
    set(handles.text99,'Position', (get(handles.text99,'Position')-(val_a)));
    set(handles.bot_time1_1,'Position', (get(handles.bot_time1_1,'Position')-(val_a)));
    set(handles.bot_time1_2,'Position', (get(handles.bot_time1_2,'Position')-(val_a)));
    set(handles.bot_time1_3,'Position', (get(handles.bot_time1_3,'Position')-(val_a)));
    set(handles.text98,'Position', (get(handles.text98,'Position')-(val_a)));
    set(handles.bot_time2_1,'Position', (get(handles.bot_time2_1,'Position')-(val_a)));
    set(handles.bot_time2_2,'Position', (get(handles.bot_time2_2,'Position')-(val_a)));
    set(handles.bot_time2_3,'Position', (get(handles.bot_time2_3,'Position')-(val_a)));
    set(handles.text91,'Position', (get(handles.text91,'Position')-(val_a)));
    set(handles.bot_repeat,'Position', (get(handles.bot_repeat,'Position')-(val_a)));
    set(handles.text90,'Position', (get(handles.text90,'Position')-(val_a)));
    set(handles.bot_absorpmode,'Position', (get(handles.bot_absorpmode,'Position')-(val_a)));
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end

end

bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
function bot_masstrans_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});

function bot_extrad_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterC,'String'));
if get(handles.bot_extrad,'Value') == 1 && str2double(get(handles.Counter2,'String')) == 1
    set(handles.text99,'Visible','on');
    set(handles.bot_time1_1,'Visible','on');
    set(handles.bot_time1_2,'Visible','on');
    set(handles.bot_time1_3,'Visible','on');
    set(handles.text98,'Visible','on');
    set(handles.bot_time2_1,'Visible','on');
    set(handles.bot_time2_2,'Visible','on');
    set(handles.bot_time2_3,'Visible','on');
    set(handles.text91,'Visible','on');
    set(handles.bot_repeat,'Visible','on');
    set(handles.text90,'Visible','on');
    set(handles.bot_absorpmode,'Visible','on');
    
    set(handles.Counter2,'String','2');
    
    val_a = [0 100 0 0];
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
elseif get(handles.bot_extrad,'Value') == 2 && str2double(get(handles.Counter2,'String')) == 2
    set(handles.text99,'Visible','off');
    set(handles.bot_time1_1,'Visible','off');
    set(handles.bot_time1_2,'Visible','off');
    set(handles.bot_time1_3,'Visible','off');
    set(handles.text98,'Visible','off');
    set(handles.bot_time2_1,'Visible','off');
    set(handles.bot_time2_2,'Visible','off');
    set(handles.bot_time2_3,'Visible','off');
    set(handles.bot_repeat,'Visible','off');
    set(handles.bot_absorpmode,'Visible','off');
    set(handles.text91,'Visible','off');
    set(handles.bot_repeat,'Visible','off');
    set(handles.text90,'Visible','off');
    set(handles.bot_absorpmode,'Visible','off');
    
    set(handles.Counter2,'String','1');
    
    val_a = [0 -100 0 0];
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
end

bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
function bot_extrad_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});


%% TOP Boundaries ===========================================================================

%% List Box -------------------------------------------------------------------------------------------------------
function top_masstrans_3_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'EXP','LIN'});
function top_absorpmode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'RAND','MAX'});
function top_extrad_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});
function top_masstrans_1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});
function top_flame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});
function top_repeat_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});

%----------------------------------------------
function top_extrad_Callback(hObject, eventdata, handles)
uicontrol_4 = str2double(get(handles.CounterE,'String'));
if get(handles.top_extrad,'Value') == 1 && str2double(get(handles.Counter3,'String')) == 1
    set(handles.text47,'Visible','on');
    set(handles.top_time1_1,'Visible','on');
    set(handles.top_time1_2,'Visible','on');
    set(handles.top_time1_3,'Visible','on');
    set(handles.text46,'Visible','on');
    set(handles.top_time2_1,'Visible','on');
    set(handles.top_time2_2,'Visible','on');
    set(handles.top_time2_3,'Visible','on');
    set(handles.text39,'Visible','on');
    set(handles.top_repeat,'Visible','on');
    set(handles.text38,'Visible','on');
    set(handles.top_absorpmode,'Visible','on');
    
    set(handles.Counter3,'String','2');
    
    val_a = [0 100 0 0];
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
elseif get(handles.top_extrad,'Value') == 2 && str2double(get(handles.Counter3,'String')) == 2
    set(handles.text47,'Visible','off');
    set(handles.top_time1_1,'Visible','off');
    set(handles.top_time1_2,'Visible','off');
    set(handles.top_time1_3,'Visible','off');
    set(handles.text46,'Visible','off');
    set(handles.top_time2_1,'Visible','off');
    set(handles.top_time2_2,'Visible','off');
    set(handles.top_time2_3,'Visible','off');
    set(handles.text39,'Visible','off');
    set(handles.top_repeat,'Visible','off');
    set(handles.text38,'Visible','off');
    set(handles.top_absorpmode,'Visible','off');
    
    set(handles.Counter3,'String','1');
    
    val_a = [0 -100 0 0];
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
end

top = get(handles.top_rad,'Position');
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0)
        set(handles.tb_slider,'Visible','off');
    end

function top_masstrans_1_Callback(hObject, eventdata, handles)
uicontrol_3 = str2double(get(handles.CounterD,'String'));
uicontrol_4 = str2double(get(handles.CounterE,'String'));

if get(handles.top_masstrans_1,'Value') == 1 && str2double(get(handles.Counter4,'String')) == 1
    set(handles.top_masstrans_2,'Visible','on');
    set(handles.top_masstrans_3,'Visible','on');
    set(handles.top_masstrans_4,'Visible','on');
    set(handles.top_masstrans_5,'Visible','on');
    set(handles.top_mt_add,'Visible','on');
    set(handles.top_mt_rem,'Visible','on');
    
    for j = 2:uicontrol_3
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Visible','on');
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Visible','on');
    end
    
    set(handles.Counter4,'String','2');
    
    val_a = [0 25*uicontrol_3 0 0];
    
    set(handles.text44,'Position',(get(handles.text44,'Position')-(val_a)));
    set(handles.top_outtemptime_1,'Position', (get(handles.top_outtemptime_1,'Position')-(val_a)));
    set(handles.top_outtemptime_2,'Position', (get(handles.top_outtemptime_2,'Position')-(val_a)));
    set(handles.text43,'Position', (get(handles.text43,'Position')-(val_a)));
    set(handles.top_convcoeff_1,'Position',(get(handles.top_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text48,'Position', (get(handles.text48,'Position')-(val_a)));
    set(handles.top_extrad,'Position', (get(handles.top_extrad,'Position')-(val_a)));
    set(handles.text47,'Position', (get(handles.text47,'Position')-(val_a)));
    set(handles.top_time1_1,'Position', (get(handles.top_time1_1,'Position')-(val_a)));
    set(handles.top_time1_2,'Position', (get(handles.top_time1_2,'Position')-(val_a)));
    set(handles.top_time1_3,'Position', (get(handles.top_time1_3,'Position')-(val_a)));
    set(handles.text46,'Position', (get(handles.text46,'Position')-(val_a)));
    set(handles.top_time2_1,'Position', (get(handles.top_time2_1,'Position')-(val_a)));
    set(handles.top_time2_2,'Position', (get(handles.top_time2_2,'Position')-(val_a)));
    set(handles.top_time2_3,'Position', (get(handles.top_time2_3,'Position')-(val_a)));
    set(handles.text39,'Position', (get(handles.text39,'Position')-(val_a)));
    set(handles.top_repeat,'Position', (get(handles.top_repeat,'Position')-(val_a)));
    set(handles.text38,'Position', (get(handles.text38,'Position')-(val_a)));
    set(handles.top_absorpmode,'Position', (get(handles.top_absorpmode,'Position')-(val_a)));
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
elseif get(handles.top_masstrans_1,'Value') == 2 && str2double(get(handles.Counter4,'String')) == 2
    set(handles.top_masstrans_2,'Visible','off');
    set(handles.top_masstrans_3,'Visible','off');
    set(handles.top_masstrans_4,'Visible','off');
    set(handles.top_masstrans_5,'Visible','off');
    set(handles.top_mt_add,'Visible','off');
    set(handles.top_mt_rem,'Visible','off');
    
    for j = 2:uicontrol_3
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Visible','off');
    end
    
    set(handles.Counter4,'String','1');
    
    val_a = [0 -25*uicontrol_3 0 0];
    
    set(handles.text44,'Position',(get(handles.text44,'Position')-(val_a)));
    set(handles.top_outtemptime_1,'Position', (get(handles.top_outtemptime_1,'Position')-(val_a)));
    set(handles.top_outtemptime_2,'Position', (get(handles.top_outtemptime_2,'Position')-(val_a)));
    set(handles.text43,'Position', (get(handles.text43,'Position')-(val_a)));
    set(handles.top_convcoeff_1,'Position',(get(handles.top_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text48,'Position', (get(handles.text48,'Position')-(val_a)));
    set(handles.top_extrad,'Position', (get(handles.top_extrad,'Position')-(val_a)));
    set(handles.text47,'Position', (get(handles.text47,'Position')-(val_a)));
    set(handles.top_time1_1,'Position', (get(handles.top_time1_1,'Position')-(val_a)));
    set(handles.top_time1_2,'Position', (get(handles.top_time1_2,'Position')-(val_a)));
    set(handles.top_time1_3,'Position', (get(handles.top_time1_3,'Position')-(val_a)));
    set(handles.text46,'Position', (get(handles.text46,'Position')-(val_a)));
    set(handles.top_time2_1,'Position', (get(handles.top_time2_1,'Position')-(val_a)));
    set(handles.top_time2_2,'Position', (get(handles.top_time2_2,'Position')-(val_a)));
    set(handles.top_time2_3,'Position', (get(handles.top_time2_3,'Position')-(val_a)));
    set(handles.text39,'Position', (get(handles.text39,'Position')-(val_a)));
    set(handles.top_repeat,'Position', (get(handles.top_repeat,'Position')-(val_a)));
    set(handles.text38,'Position', (get(handles.text38,'Position')-(val_a)));
    set(handles.top_absorpmode,'Position', (get(handles.top_absorpmode,'Position')-(val_a)));
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
end

top = get(handles.top_rad,'Position');
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0)
        set(handles.tb_slider,'Visible','off');
    end
    
function top_flame_Callback(hObject, eventdata, handles)
uicontrol_4 = str2double(get(handles.CounterE,'String'));
if get(handles.top_flame,'Value') == 1 && str2double(get(handles.Counter5,'String')) == 1
    set(handles.text42,'Visible','on');
    set(handles.top_igntmassflux_1,'Visible','on');
    set(handles.top_igntmassflux_2,'Visible','on');
    set(handles.text41,'Visible','on');
    set(handles.top_outtemp,'Visible','on');
    set(handles.text40,'Visible','on');
    set(handles.top_convcoeff_2,'Visible','on');
    set(handles.text49,'Visible','on');
    set(handles.top_rad,'Visible','on');
    set(handles.top_imf_add,'Visible','on');
    set(handles.top_imf_rem,'Visible','on');
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Visible','on');        
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Visible','on');
    end
    
    set(handles.Counter5,'String','2');
    
elseif get(handles.top_flame,'Value') == 2 && str2double(get(handles.Counter5,'String')) == 2
    set(handles.text42,'Visible','off');
    set(handles.top_igntmassflux_1,'Visible','off');
    set(handles.top_igntmassflux_2,'Visible','off');
    set(handles.text41,'Visible','off');
    set(handles.top_outtemp,'Visible','off');
    set(handles.text40,'Visible','off');
    set(handles.top_convcoeff_2,'Visible','off');
    set(handles.text49,'Visible','off');
    set(handles.top_rad,'Visible','off');
    set(handles.top_imf_add,'Visible','off');
    set(handles.top_imf_rem,'Visible','off');
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Visible','off');
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Visible','off');
    end
    
    set(handles.Counter5,'String','1');
    
end

top = get(handles.top_rad,'Position');
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0)
        set(handles.tb_slider,'Visible','off');
    end
    
%% TEXT INPUT ------------------------------------------------------------------------------------------
function top_convcoeff_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_outtemptime_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_outtemptime_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time1_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time1_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time1_3_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time2_1_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time2_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_time2_3_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_outtemp_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_convcoeff_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_rad_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_masstrans_4_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_masstrans_5_Callback(hObject, eventdata, handles)
get(hObject,'String');
function top_igntmassflux_2_Callback(hObject, eventdata, handles)
get(hObject,'String');
function select_cmp_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile({'*.cmp',...
    'Component Files (*.cmp)';'*.txt', 'Text Files (*.txt)';...
    '*.*','All Files (*.*)'},'Select the Components File'); %add default path
pathn = fullfile(PathName,FileName);
curpath = fullfile(pwd,FileName);
if isequal(FileName,0) %if no file is chosen or canceled then display Cancel
    disp('User selected Cancel')
else % else continue
    disp(['User selected ', fullfile(PathName, FileName)])
    if isequal(curpath,pathn) % determine if file is in current directory or not
        fdd = fopen(FileName); %open file
        file_strings = textscan(fdd, '%s', 'Delimiter', ':'); %scan file and make new line after ':'
        fclose(fdd); % close file
    else
        copyfile(fullfile(PathName, FileName)); % copy file into directory for Matlab
        fdd = fopen(FileName);
        file_strings = textscan(fdd, '%s', 'Delimiter', ':');
        fclose(fdd);
        delete(FileName); % delete file
    end
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
        if strcmp(file_strings{1}{file_strings_ix},'STATE') % if loop reaches string 'COMPONENT'...
            file_strings_ix = file_strings_ix+1; %add 1 to line counter
            state_ix=(state_ix)+1;
            state(state_ix,1) = cellstr(file_strings{1}{file_strings_ix});
            file_strings_ix = file_strings_ix+1;
        end
    end
    
    cmp_val = find(strncmp(state,'G',3));
    index_value = size(cmp_val,1);
    for j = 1:index_value
        cmp_2(j,1) = cmp(cmp_val(j));
    end
    
    disp(cmp);
    disp(cmp_2);
    disp(state);
    
    set(handles.top_masstrans_2, 'String', cmp_2)
    set(handles.bot_masstrans_2, 'String', cmp_2)
    set(handles.top_igntmassflux_1, 'String', cmp_2)
    set(handles.bot_igntmassflux_1, 'String', cmp_2)
end

%%==================OBJECT STRUCTURE=========================================================================
function L_MassFrac1_1_Callback(hObject, eventdata, handles)

function L_MassFrac1_1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function L_MassFrac1_2_Callback(hObject, eventdata, handles)

function L_MassFrac1_2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function add_layer_Callback(hObject, eventdata, handles)

function remove_layer_Callback(hObject, eventdata, handles)

function L_thick1_Callback(hObject, eventdata, handles)

function L_thick1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function L_temp1_Callback(hObject, eventdata, handles)

function L_temp1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% ==================ADD and REMOVE BUTTONS======================================================================================
%% removes most recent gas input boxes on bottom Mass Transport
function bot_mt_add_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterB,'String')); %calls value from counter
uicontrol_2 = str2double(get(handles.CounterC,'String'));%calls value from counter
if lt(uicontrol_ix,size(get(handles.bot_masstrans_2,'String'),1)) %if the counter is less than the amount of components
    set(handles.CounterB,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterB,'String')))+1)))); %add 1 to counter
    positiony = -24 * uicontrol_ix; %multiply to increase the position avoids overlapping
    uicontrol_ix = str2double(get(handles.CounterB,'String'));
    
    % creates listbox and textbox for mass transport
    uicontrol('Parent',handles.uipanelb,'Style', 'popup',...
        'String',(get(handles.bot_masstrans_2,'String')),...
        'Position',(get(handles.bot_masstrans_2,'Position'))+[0 positiony 0 0],...
        'Tag',sprintf('bot_masstrans_2_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'popup',... % findobj('Tag','uipnelb') = handles.uipanelb
        'String',(get(handles.bot_masstrans_3,'String')),...
        'Position',(get(handles.bot_masstrans_3,'Position'))+[0 positiony 0 0],...
        'Tag',sprintf('bot_masstrans_3_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'edit',...
        'String','0','Position',(get(handles.bot_masstrans_4,'Position'))+[0 positiony+2 0 0],...
        'Tag',sprintf('bot_masstrans_4_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'edit',...
        'String','0','Position',(get(handles.bot_masstrans_5,'Position'))+[0 positiony+2 0 0],...
        'Tag',sprintf('bot_masstrans_5_%d',int32(uicontrol_ix)),'Visible','on'); %'Callback', @setmap,
    
    %% Positions
    
    % item gets pushed down once inputs are created
    
    val_a = [0 25 0 0];
    
    set(handles.text96,'Position',(get(handles.text96,'Position')-(val_a)));
    set(handles.bot_outtemptime_1,'Position', (get(handles.bot_outtemptime_1,'Position')-(val_a)));
    set(handles.bot_outtemptime_2,'Position', (get(handles.bot_outtemptime_2,'Position')-(val_a)));
    set(handles.text95,'Position', (get(handles.text95,'Position')-(val_a)));
    set(handles.bot_convcoeff_1,'Position',(get(handles.bot_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text100,'Position', (get(handles.text100,'Position')-(val_a)));
    set(handles.bot_extrad,'Position', (get(handles.bot_extrad,'Position')-(val_a)));
    set(handles.text99,'Position', (get(handles.text99,'Position')-(val_a)));
    set(handles.bot_time1_1,'Position', (get(handles.bot_time1_1,'Position')-(val_a)));
    set(handles.bot_time1_2,'Position', (get(handles.bot_time1_2,'Position')-(val_a)));
    set(handles.bot_time1_3,'Position', (get(handles.bot_time1_3,'Position')-(val_a)));
    set(handles.text98,'Position', (get(handles.text98,'Position')-(val_a)));
    set(handles.bot_time2_1,'Position', (get(handles.bot_time2_1,'Position')-(val_a)));
    set(handles.bot_time2_2,'Position', (get(handles.bot_time2_2,'Position')-(val_a)));
    set(handles.bot_time2_3,'Position', (get(handles.bot_time2_3,'Position')-(val_a)));
    set(handles.text91,'Position', (get(handles.text91,'Position')-(val_a)));
    set(handles.bot_repeat,'Position', (get(handles.bot_repeat,'Position')-(val_a)));
    set(handles.text90,'Position', (get(handles.text90,'Position')-(val_a)));
    set(handles.bot_absorpmode,'Position', (get(handles.bot_absorpmode,'Position')-(val_a)));
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2 %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 24 0 0];
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_b)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_b)));
    
    bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0) %Updates Slider where it should pop or not
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
end

%% removes most recent gas input boxes on bottom Mass Transport
function bot_mt_rem_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterB,'String'));
uicontrol_2 = str2double(get(handles.CounterC,'String'));
if gt(uicontrol_ix,1)
    
    uicontrol_ix = str2double(get(handles.CounterB,'String'));
    set(handles.CounterB,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterB,'String')))-1))));
    
    bot_masstrans_2 = findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(uicontrol_ix))));
    bot_masstrans_3 = findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(uicontrol_ix))));
    bot_masstrans_4 = findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(uicontrol_ix))));
    bot_masstrans_5 = findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(uicontrol_ix))));
    
    delete(bot_masstrans_2);
    delete(bot_masstrans_3);
    delete(bot_masstrans_4);
    delete(bot_masstrans_5);
    
    val_a = [0 -25 0 0];
    
    set(handles.text96,'Position',(get(handles.text96,'Position')-(val_a)));
    set(handles.bot_outtemptime_1,'Position', (get(handles.bot_outtemptime_1,'Position')-(val_a)));
    set(handles.bot_outtemptime_2,'Position', (get(handles.bot_outtemptime_2,'Position')-(val_a)));
    set(handles.text95,'Position', (get(handles.text95,'Position')-(val_a)));
    set(handles.bot_convcoeff_1,'Position',(get(handles.bot_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text100,'Position', (get(handles.text100,'Position')-(val_a)));
    set(handles.bot_extrad,'Position', (get(handles.bot_extrad,'Position')-(val_a)));
    set(handles.text99,'Position', (get(handles.text99,'Position')-(val_a)));
    set(handles.bot_time1_1,'Position', (get(handles.bot_time1_1,'Position')-(val_a)));
    set(handles.bot_time1_2,'Position', (get(handles.bot_time1_2,'Position')-(val_a)));
    set(handles.bot_time1_3,'Position', (get(handles.bot_time1_3,'Position')-(val_a)));
    set(handles.text98,'Position', (get(handles.text98,'Position')-(val_a)));
    set(handles.bot_time2_1,'Position', (get(handles.bot_time2_1,'Position')-(val_a)));
    set(handles.bot_time2_2,'Position', (get(handles.bot_time2_2,'Position')-(val_a)));
    set(handles.bot_time2_3,'Position', (get(handles.bot_time2_3,'Position')-(val_a)));
    set(handles.text91,'Position', (get(handles.text91,'Position')-(val_a)));
    set(handles.bot_repeat,'Position', (get(handles.bot_repeat,'Position')-(val_a)));
    set(handles.text90,'Position', (get(handles.text90,'Position')-(val_a)));
    set(handles.bot_absorpmode,'Position', (get(handles.bot_absorpmode,'Position')-(val_a)));
    
    set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
    set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
    
    set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
    set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
    set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 -24 0 0];
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_b)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_b)));
    
    bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
end

%% adds gas input boxes on Bot Ignition Mass Fluxes
function bot_imf_add_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterC,'String'));
if lt(uicontrol_ix,size(get(handles.bot_masstrans_2,'String'),1))
    set(handles.CounterC,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterC,'String')))+1))));
    positiony = -24 * uicontrol_ix;
    uicontrol_ix = str2double(get(handles.CounterC,'String'));
    
    handle1 = sprintf('bot_igntmassflux_1_%d',int32(uicontrol_ix));
    handle2 = sprintf('bot_igntmassflux_2_%d',int32(uicontrol_ix));
    
    uicontrol('Parent',handles.uipanelb,'Style','popup',...
        'String',(get(handles.bot_masstrans_2,'String')),...
        'Position',(get(handles.bot_igntmassflux_1,'Position'))+[0 positiony 0 0],...
        'Tag',handle1,'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style','edit',...
        'String','0','Position',(get(handles.bot_igntmassflux_2,'Position'))+[0 positiony+2 0 0],...
        'Tag',handle2,'Visible','on'); %'Callback', @setmap,
    
    val_a = [0 25 0 0];
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    val_b = [0 24 0 0];
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_b)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_b)));
    
    bot = get(handles.bot_rad,'Position');
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0)
        set(handles.bb_slider,'Visible','off');
    end
end

%% removes most recent gas input boxes on bottom Ignition Mass Fluxes
function bot_imf_rem_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterC,'String'));

if gt(uicontrol_ix,1)
    
    uicontrol_ix = str2double(get(handles.CounterC,'String'));
    set(handles.CounterC,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterC,'String')))-1))));
    
    bot_igntmassflux_1 = findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(uicontrol_ix))));
    bot_igntmassflux_2 = findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(uicontrol_ix))));
    
    delete(bot_igntmassflux_1);
    delete(bot_igntmassflux_2);
    
    val_a = [0 -25 0 0];
    set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
    set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
    set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
    set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
    set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
    set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
    
    val_b = [0 -24 0 0];
    set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_b)));
    set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_b)));
    
    bot = get(handles.bot_rad,'Position');
    %     bot1 = get(handles.top_masstrans_1,'Position');
    %     bot1=bot1(2);
    bot = bot(2);
    bot_1 = get(handles.bot_flame,'Position');
    bot_1 = bot_1(2);
    if le(bot,0) && strcmp(get(handles.bot_rad,'Visible'),'on') || le(bot_1,0) %|| ge(bot1,398)
        set(handles.bb_slider,'Visible','on');
    elseif gt(bot,0) || strcmp(get(handles.bot_rad,'Visible'),'off') || gt(bot_1,0) %&& lt(bot1,398)
        set(handles.bb_slider,'Visible','off');
    end
end

%% adds gas input boxes on Mass Transport
function top_mt_add_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterD,'String'));
uicontrol_4 = str2double(get(handles.CounterE,'String'));
if lt(uicontrol_ix,size(get(handles.top_masstrans_2,'String'),1))
    set(handles.CounterD,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterD,'String')))+1))));
    positiony = -24 * uicontrol_ix;
    uicontrol_ix = str2double(get(handles.CounterD,'String'));
    handle1 = sprintf('top_masstrans_2_%d',int32(uicontrol_ix));
    handle2 = sprintf('top_masstrans_3_%d',int32(uicontrol_ix));
    handle3 = sprintf('top_masstrans_4_%d',int32(uicontrol_ix));
    handle4 = sprintf('top_masstrans_5_%d',int32(uicontrol_ix));
    
    uicontrol('Parent',handles.uipanelt,'Style', 'popup',...
        'String',(get(handles.top_masstrans_2,'String')),...
        'Position',(get(handles.top_masstrans_2,'Position'))+[0 positiony 0 0],'Tag',handle1,...
        'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelt,'Style', 'popup',... % findobj('Tag','uipnelb') = handles.uipanelt
        'String',(get(handles.top_masstrans_3,'String')),...
        'Position',(get(handles.top_masstrans_3,'Position'))+[0 positiony 0 0],'Tag',handle2,...
        'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelt,'Style', 'edit',...
        'String','0','Position',(get(handles.top_masstrans_4,'Position'))+[0 positiony+2 0 0],'Tag',handle3,...
        'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelt,'Style', 'edit',...
        'String','0','Position',(get(handles.top_masstrans_5,'Position'))+[0 positiony+2 0 0],'Tag',handle4,...
        'Visible','on'); %'Callback', @setmap,
    
    val_a = [0 25 0 0];
    set(handles.text44,'Position',(get(handles.text44,'Position')-(val_a)));
    set(handles.top_outtemptime_1,'Position', (get(handles.top_outtemptime_1,'Position')-(val_a)));
    set(handles.top_outtemptime_2,'Position', (get(handles.top_outtemptime_2,'Position')-(val_a)));
    set(handles.text43,'Position', (get(handles.text43,'Position')-(val_a)));
    set(handles.top_convcoeff_1,'Position',(get(handles.top_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text48,'Position', (get(handles.text48,'Position')-(val_a)));
    set(handles.top_extrad,'Position', (get(handles.top_extrad,'Position')-(val_a)));
    set(handles.text47,'Position', (get(handles.text47,'Position')-(val_a)));
    set(handles.top_time1_1,'Position', (get(handles.top_time1_1,'Position')-(val_a)));
    set(handles.top_time1_2,'Position', (get(handles.top_time1_2,'Position')-(val_a)));
    set(handles.top_time1_3,'Position', (get(handles.top_time1_3,'Position')-(val_a)));
    set(handles.text46,'Position', (get(handles.text46,'Position')-(val_a)));
    set(handles.top_time2_1,'Position', (get(handles.top_time2_1,'Position')-(val_a)));
    set(handles.top_time2_2,'Position', (get(handles.top_time2_2,'Position')-(val_a)));
    set(handles.top_time2_3,'Position', (get(handles.top_time2_3,'Position')-(val_a)));
    set(handles.text39,'Position', (get(handles.text39,'Position')-(val_a)));
    set(handles.top_repeat,'Position', (get(handles.top_repeat,'Position')-(val_a)));
    set(handles.text38,'Position', (get(handles.text38,'Position')-(val_a)));
    set(handles.top_absorpmode,'Position', (get(handles.top_absorpmode,'Position')-(val_a)));
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
    val_b = [0 24 0 0];
    set(handles.top_mt_add,'Position', (get(handles.top_mt_add,'Position')-(val_b)));
    set(handles.top_mt_rem,'Position', (get(handles.top_mt_rem,'Position')-(val_b)));
    
    top = get(handles.top_rad,'Position');
    %     top1 = get(handles.top_masstrans_1,'Position');
    %     top1=top1(2);
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0) %|| ge(top1,398)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0) %&& lt(top1,398)
        set(handles.tb_slider,'Visible','off');
    end
end

%% removes most recent gas input boxes on top Mass Transport
function top_mt_rem_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterD,'String'));
uicontrol_4 = str2double(get(handles.CounterE,'String'));
if gt(uicontrol_ix,1)
    
    uicontrol_ix = str2double(get(handles.CounterD,'String'));
    set(handles.CounterD,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterD,'String')))-1))));
    
    top_masstrans_2 = findobj('Tag',(sprintf('top_masstrans_2_%d',int32(uicontrol_ix))));
    top_masstrans_3 = findobj('Tag',(sprintf('top_masstrans_3_%d',int32(uicontrol_ix))));
    top_masstrans_4 = findobj('Tag',(sprintf('top_masstrans_4_%d',int32(uicontrol_ix))));
    top_masstrans_5 = findobj('Tag',(sprintf('top_masstrans_5_%d',int32(uicontrol_ix))));
    
    delete(top_masstrans_2);
    delete(top_masstrans_3);
    delete(top_masstrans_4);
    delete(top_masstrans_5);
    
    val_a = [0 -25 0 0];
    set(handles.text44,'Position',(get(handles.text44,'Position')-(val_a)));
    set(handles.top_outtemptime_1,'Position', (get(handles.top_outtemptime_1,'Position')-(val_a)));
    set(handles.top_outtemptime_2,'Position', (get(handles.top_outtemptime_2,'Position')-(val_a)));
    set(handles.text43,'Position', (get(handles.text43,'Position')-(val_a)));
    set(handles.top_convcoeff_1,'Position',(get(handles.top_convcoeff_1,'Position')-(val_a)) );
    
    set(handles.text48,'Position', (get(handles.text48,'Position')-(val_a)));
    set(handles.top_extrad,'Position', (get(handles.top_extrad,'Position')-(val_a)));
    set(handles.text47,'Position', (get(handles.text47,'Position')-(val_a)));
    set(handles.top_time1_1,'Position', (get(handles.top_time1_1,'Position')-(val_a)));
    set(handles.top_time1_2,'Position', (get(handles.top_time1_2,'Position')-(val_a)));
    set(handles.top_time1_3,'Position', (get(handles.top_time1_3,'Position')-(val_a)));
    set(handles.text46,'Position', (get(handles.text46,'Position')-(val_a)));
    set(handles.top_time2_1,'Position', (get(handles.top_time2_1,'Position')-(val_a)));
    set(handles.top_time2_2,'Position', (get(handles.top_time2_2,'Position')-(val_a)));
    set(handles.top_time2_3,'Position', (get(handles.top_time2_3,'Position')-(val_a)));
    set(handles.text39,'Position', (get(handles.text39,'Position')-(val_a)));
    set(handles.top_repeat,'Position', (get(handles.top_repeat,'Position')-(val_a)));
    set(handles.text38,'Position', (get(handles.text38,'Position')-(val_a)));
    set(handles.top_absorpmode,'Position', (get(handles.top_absorpmode,'Position')-(val_a)));
    
    set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
    set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
    
    set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
    set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
    set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    for j = 2:uicontrol_4
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));        
    end
    
    val_b = [0 -24 0 0];
    set(handles.top_mt_add,'Position', (get(handles.top_mt_add,'Position')-(val_b)));
    set(handles.top_mt_rem,'Position', (get(handles.top_mt_rem,'Position')-(val_b)));
    
    top = get(handles.top_rad,'Position');
    %     top1 = get(handles.top_masstrans_1,'Position');
    %     top1=top1(2);
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0) %|| ge(top1,398)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0) %&& lt(top1,398)
        set(handles.tb_slider,'Visible','off');
    end
end

%% adds gas input boxes on Top Ignition Mass Fluxes
function top_imf_add_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterE,'String'));
if lt(uicontrol_ix,size(get(handles.top_masstrans_2,'String'),1))
    set(handles.CounterE,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterE,'String')))+1))));
    positiony = -24 * uicontrol_ix;
    uicontrol_ix = str2double(get(handles.CounterE,'String'));
    
    handle1 = sprintf('top_igntmassflux_1_%d',int32(uicontrol_ix));
    handle2 = sprintf('top_igntmassflux_2_%d',int32(uicontrol_ix));
    
    uicontrol('Parent',handles.uipanelt,'Style','popup',...
        'String',(get(handles.top_masstrans_2,'String')),...
        'Position',(get(handles.top_igntmassflux_1,'Position'))+[0 positiony 0 0],...
        'Tag',handle1,'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelt,'Style','edit',...
        'String','0','Position',(get(handles.top_igntmassflux_2,'Position'))+[0 positiony+2 0 0],...
        'Tag',handle2,'Visible','on'); %'Callback', @setmap,
    
    val_a = [0 25 0 0];
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    val_b = [0 24 0 0];
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_b)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_b)));
    
    top = get(handles.top_rad,'Position');
    %     top1 = get(handles.top_masstrans_1,'Position');
    %     top1=top1(2);
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0) %|| ge(top1,398)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0) %&& lt(top1,398)
        set(handles.tb_slider,'Visible','off');
    end
end

%% removes most recent gas input boxes on Top Ignition Mass Fluxes
function top_imf_rem_Callback(hObject, eventdata, handles)
uicontrol_ix = str2double(get(handles.CounterE,'String'));

if gt(uicontrol_ix,1)
    
    uicontrol_ix = str2double(get(handles.CounterE,'String'));
    set(handles.CounterE,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterE,'String')))-1))));
    
    top_igntmassflux_1 = findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(uicontrol_ix))));
    top_igntmassflux_2 = findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(uicontrol_ix))));
    
    delete(top_igntmassflux_1);
    delete(top_igntmassflux_2);
    
    val_a = [0 -25 0 0];
    set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
    set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
    set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
    set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
    set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
    set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
    
    val_b = [0 -24 0 0];
    set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_b)));
    set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_b)));
    
    top = get(handles.top_rad,'Position');
    %     top1 = get(handles.top_masstrans_1,'Position');
    %     top1=top1(2);
    top = top(2);
    top_1 = get(handles.top_flame,'Position');
    top_1 = top_1(2);
    if le(top,0) && strcmp(get(handles.top_rad,'Visible'),'on') || le(top_1,0) %|| ge(top1,398)
        set(handles.tb_slider,'Visible','on');
    elseif gt(top,0) || strcmp(get(handles.top_rad,'Visible'),'off') || gt(top_1,0) %&& lt(top1,398)
        set(handles.tb_slider,'Visible','off');
    end
end

%% allow scrolling for Top boundary when information overlaps.
function bb_slider_Callback(hObject, eventdata, handles)
bb_slider = get(handles.bb_slider,'Value');
disp(bb_slider);
%%
% bb_slider= 40*bb_slider;
% % bb_slider= 1/bb_slider;
% % bb_slider = sqrt(bb_slider);
% val_a = [1 -bb_slider 1 1];
% %%
% set(handles.text97,'Position',(get(handles.text97,'Position')-(val_a)));
% set(handles.bot_masstrans_1,'Position', (get(handles.bot_masstrans_1,'Position')-(val_a)));
%
% set(handles.bot_masstrans_2,'Position', (get(handles.bot_masstrans_2,'Position')-(val_a)));
% set(handles.bot_masstrans_3,'Position', (get(handles.bot_masstrans_3,'Position')-(val_a)));
% set(handles.bot_masstrans_4,'Position', (get(handles.bot_masstrans_4,'Position')-(val_a)));
% set(handles.bot_masstrans_5,'Position', (get(handles.bot_masstrans_5,'Position')-(val_a)));
%
% set(handles.text96,'Position',(get(handles.text96,'Position')-(val_a)));
% set(handles.bot_outtemptime_1,'Position', (get(handles.bot_outtemptime_1,'Position')-(val_a)));
% set(handles.bot_outtemptime_2,'Position', (get(handles.bot_outtemptime_2,'Position')-(val_a)));
% set(handles.text95,'Position', (get(handles.text95,'Position')-(val_a)));
% set(handles.bot_convcoeff_1,'Position',(get(handles.bot_convcoeff_1,'Position')-(val_a)) );
%
% set(handles.text100,'Position', (get(handles.text100,'Position')-(val_a)));
% set(handles.bot_extrad,'Position', (get(handles.bot_extrad,'Position')-(val_a)));
% set(handles.text99,'Position', (get(handles.text99,'Position')-(val_a)));
% set(handles.bot_time1_1,'Position', (get(handles.bot_time1_1,'Position')-(val_a)));
% set(handles.bot_time1_2,'Position', (get(handles.bot_time1_2,'Position')-(val_a)));
% set(handles.bot_time1_3,'Position', (get(handles.bot_time1_3,'Position')-(val_a)));
% set(handles.text98,'Position', (get(handles.text98,'Position')-(val_a)));
% set(handles.bot_time2_1,'Position', (get(handles.bot_time2_1,'Position')-(val_a)));
% set(handles.bot_time2_2,'Position', (get(handles.bot_time2_2,'Position')-(val_a)));
% set(handles.bot_time2_3,'Position', (get(handles.bot_time2_3,'Position')-(val_a)));
% set(handles.text91,'Position', (get(handles.text91,'Position')-(val_a)));
% set(handles.bot_repeat,'Position', (get(handles.bot_repeat,'Position')-(val_a)));
% set(handles.text90,'Position', (get(handles.text90,'Position')-(val_a)));
% set(handles.bot_absorpmode,'Position', (get(handles.bot_absorpmode,'Position')-(val_a)));
%
% set(handles.text89,'Position', (get(handles.text89,'Position')-(val_a)));
% set(handles.bot_flame,'Position', (get(handles.bot_flame,'Position')-(val_a)));
%
% set(handles.text94,'Position', (get(handles.text94,'Position')-(val_a)));
% set(handles.bot_igntmassflux_1,'Position', (get(handles.bot_igntmassflux_1,'Position')-(val_a)));
% set(handles.bot_igntmassflux_2,'Position', (get(handles.bot_igntmassflux_2,'Position')-(val_a)));
% set(handles.bot_imf_add,'Position', (get(handles.bot_imf_add,'Position')-(val_a)));
% set(handles.bot_imf_rem,'Position', (get(handles.bot_imf_rem,'Position')-(val_a)));
% set(handles.text93,'Position', (get(handles.text93,'Position')-(val_a)));
% set(handles.bot_outtemp,'Position', (get(handles.bot_outtemp,'Position')-(val_a)));
% set(handles.text92,'Position', (get(handles.text92,'Position')-(val_a)));
% set(handles.bot_convcoeff_2,'Position', (get(handles.bot_convcoeff_2,'Position')-(val_a)));
% set(handles.text101,'Position', (get(handles.text101,'Position')-(val_a)));
% set(handles.bot_rad,'Position', (get(handles.bot_rad,'Position')-(val_a)));
%%
% uipanelb=get(handles.uipanelb,'Position');

%% allow scrolling for Top boundary when information overlaps.
function tb_slider_Callback(hObject, eventdata, handles)
tb_slider=get(handles.tb_slider,'Value');
disp(tb_slider);
%%
% tb_slider= 40*tb_slider;
% % tb_slider= 1/tb_slider;
% % tb_slider = sqrt(tb_slider);
% val_a = [1 -tb_slider 1 1];
%
% %%
% set(handles.text45,'Position',(get(handles.text45,'Position')-(val_a)));
% set(handles.top_masstrans_1,'Position', (get(handles.top_masstrans_1,'Position')-(val_a)));
%
%     set(handles.text44,'Position',(get(handles.text44,'Position')-(val_a)));
%     set(handles.top_outtemptime_1,'Position', (get(handles.top_outtemptime_1,'Position')-(val_a)));
%     set(handles.top_outtemptime_2,'Position', (get(handles.top_outtemptime_2,'Position')-(val_a)));
%     set(handles.text43,'Position', (get(handles.text43,'Position')-(val_a)));
%     set(handles.top_convcoeff_1,'Position',(get(handles.top_convcoeff_1,'Position')-(val_a)) );
%
%     set(handles.text48,'Position', (get(handles.text48,'Position')-(val_a)));
%     set(handles.top_extrad,'Position', (get(handles.top_extrad,'Position')-(val_a)));
%     set(handles.text47,'Position', (get(handles.text47,'Position')-(val_a)));
%     set(handles.top_time1_1,'Position', (get(handles.top_time1_1,'Position')-(val_a)));
%     set(handles.top_time1_2,'Position', (get(handles.top_time1_2,'Position')-(val_a)));
%     set(handles.top_time1_3,'Position', (get(handles.top_time1_3,'Position')-(val_a)));
%     set(handles.text46,'Position', (get(handles.text46,'Position')-(val_a)));
%     set(handles.top_time2_1,'Position', (get(handles.top_time2_1,'Position')-(val_a)));
%     set(handles.top_time2_2,'Position', (get(handles.top_time2_2,'Position')-(val_a)));
%     set(handles.top_time2_3,'Position', (get(handles.top_time2_3,'Position')-(val_a)));
%     set(handles.text39,'Position', (get(handles.text39,'Position')-(val_a)));
%     set(handles.top_repeat,'Position', (get(handles.top_repeat,'Position')-(val_a)));
%     set(handles.text38,'Position', (get(handles.text38,'Position')-(val_a)));
%     set(handles.top_absorpmode,'Position', (get(handles.top_absorpmode,'Position')-(val_a)));
%
%     set(handles.text37,'Position', (get(handles.text37,'Position')-(val_a)));
%     set(handles.top_flame,'Position', (get(handles.top_flame,'Position')-(val_a)));
%
%     set(handles.text42,'Position', (get(handles.text42,'Position')-(val_a)));
%     set(handles.top_igntmassflux_1,'Position', (get(handles.top_igntmassflux_1,'Position')-(val_a)));
%     set(handles.top_igntmassflux_2,'Position', (get(handles.top_igntmassflux_2,'Position')-(val_a)));
%     set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
%     set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
%     set(handles.text41,'Position', (get(handles.text41,'Position')-(val_a)));
%     set(handles.top_outtemp,'Position', (get(handles.top_outtemp,'Position')-(val_a)));
%     set(handles.text40,'Position', (get(handles.text40,'Position')-(val_a)));
%     set(handles.top_convcoeff_2,'Position', (get(handles.top_convcoeff_2,'Position')-(val_a)));
%     set(handles.text49,'Position', (get(handles.text49,'Position')-(val_a)));
%     set(handles.top_rad,'Position', (get(handles.top_rad,'Position')-(val_a)));
%%

% uipanelt=get(handles.uipanelt,'Position');

% function bot_mt_2_Callback(hObject, eventdata, handles)
% uicontrol_ix = str2double(get(handles.CounterB,'String'));
% uicontrol_ix = uicontrol_ix-1;
% for j = 1:uicontrol_ix
%     handle1 = sprintf('bot_masstrans_2_%d',int32(uicontrol_ix));
% end
% function bot_mt_3_Callback(hObject, eventdata, handles)
%     handle2 = sprintf('bot_masstrans_3_%d',int32(uicontrol_ix));
%
% function bot_mt_4_Callback(hObject, eventdata, handles)
% handle3 = sprintf('bot_masstrans_4_%d',int32(uicontrol_ix));
%
% function bot_mt_5_Callback(hObject, eventdata, handles)
% handle4 = sprintf('bot_masstrans_5_%d',int32(uicontrol_ix));
%
% function top_mt_2_Callback(hObject, eventdata, handles)
%
% function top_mt_3_Callback(hObject, eventdata, handles)
%
% function top_mt_4_Callback(hObject, eventdata, handles)
%
% function top_mt_5_Callback(hObject, eventdata, handles)
%
%
% function bot_imf_2_Callback(hObject, eventdata, handles)
%
% function bot_imf_3_Callback(hObject, eventdata, handles)
%
% function bot_imf_4_Callback(hObject, eventdata, handles)
%
% function bot_imf_5_Callback(hObject, eventdata, handles)
%
%
% function top_imf_2_Callback(hObject, eventdata, handles)
%
% function top_imf_3_Callback(hObject, eventdata, handles)
%
% function top_imf_4_Callback(hObject, eventdata, handles)
%
% function top_imf_5_Callback(hObject, eventdata, handles)

function OB_structpush_Callback(hObject, eventdata, handles)
open(Layers_1D);
