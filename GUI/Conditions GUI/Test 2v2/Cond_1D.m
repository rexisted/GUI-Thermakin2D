
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

uicontrol('Style','text','String',cmp,'Visible','Off',...
    'Tag','cmphold');

set(handles.uipanelt,'Units','normalized');
posy = get(handles.uipanelt,'Position');
set(handles.tb_slider,'Max',posy(4)-1);
set(handles.tb_slider,'Value',posy(4)-1);
set(handles.uipanelt,'Units','pixels');

set(handles.uipanelb,'Units','normalized');
posx = get(handles.uipanelb,'Position');
set(handles.bb_slider,'Max',posx(4)-1);
set(handles.bb_slider,'Value',posx(4)-1);
set(handles.uipanelb,'Units','pixels');

addlistener(handles.bb_slider,'Value','PreSet',...
    @(hObject, eventdata)bb_slider_Callback(hObject, eventdata, handles));

addlistener(handles.tb_slider,'Value','PreSet',...
    @(hObject, eventdata)tb_slider_Callback(hObject, eventdata, handles));

movegui(handles.figure1,'north')

% --- Outputs from this function are returned to the command line.
function varargout = Cond_1D_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

function create_cnd_Callback(hObject, eventdata, handles)
%% Object Structure
obj_struct{1,1} = 'OBJECT STRUCTURE';
obj_struct{2,1} = '****************';
obj_struct{3,1} = 'FROM TOP';

Lcounter = findobj('Tag','Lcounter');
for i = 1:str2double(Lcounter.String)
    countMF = findobj('Tag',sprintf('countMF_%d',i));
    countMF_all(i)= str2double(countMF.String);
end

for j = 1:str2double(Lcounter.String)
    
    if j ~= 1
        bc = sum(countMF_all(1:j-1));
    else
        bc = 0;
    end
    
    ac = 3 + 4*(j-1) + bc;
    
    temp = findobj('Tag',sprintf('temp_%d',j));
    thick = findobj('Tag',sprintf('thick_%d',j));

    obj_struct{ac+1,1} = sprintf('THICKNESS:  %s',thick.String);
    obj_struct{ac+2,1} = sprintf('TEMPERATURE:  %s',temp.String);
    obj_struct{ac+3,1} = 'MASS FRACTIONS:';

    for jj = 1:countMF_all(j);
    massfrac2 = findobj('Tag',sprintf('mass_frac2_%d_%d',j,jj));
    massfrac1 = findobj('Tag',sprintf('mass_frac1_%d_%d',j,jj));
    masf1 = massfrac1.String{massfrac1.Value};
    masf2 = str2double(massfrac2.String);

    obj_struct{ac+3+jj,1} = sprintf('%s  %d',masf1,masf2);
    end
    obj_struct{ac+4+jj,1} = ' ';

end

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

F = char(obj_struct{:,1},obj_bound{:,1},INT_PARA{:,1});

[FileName,PathName] = uiputfile('*.cnd','Save as');
if isequal(FileName,0) %if no file is chosen or canceled then display Cancel
    disp('User selected Cancel')
else
    dlmwrite(FileName,F,'delimiter', '', 'newline', 'pc');
    disp(pwd);
    disp(PathName);
    dir_sz = size(PathName,2);
    if ~strncmp(pwd,PathName,dir_sz-1)
    movefile(FileName,PathName,'f');
    end
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

%---------YES/NO Visibility--
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

%%
set(handles.uipanelb,'Units','normalized');
posy = get(handles.uipanelb,'Position');
set(handles.bb_slider,'Max',posy(4)-1);
set(handles.bb_slider,'Value',0);
set(handles.uipanelb,'Units','normalized');
gpos = get(handles.uipanelb,'Position');
gpos(2)= 0;
display(gpos);
set(handles.uipanelb,'Position',gpos);
set(handles.uipanelb,'Units','pixels');
function bot_flame_CreateFcn(hObject, eventdata, handles) %try to minimize this.

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
    %% Sets visibility of the following options a line below depending on selected option
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
    
    %%
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
%%
set(handles.uipanelb,'Units','normalized');
posy = get(handles.uipanelb,'Position');
set(handles.bb_slider,'Max',posy(4)-1);
set(handles.bb_slider,'Value',0);
set(handles.uipanelb,'Units','normalized');
gpos = get(handles.uipanelb,'Position');
gpos(2)= 0;
display(gpos);
set(handles.uipanelb,'Position',gpos);
set(handles.uipanelb,'Units','pixels')
function bot_masstrans_1_CreateFcn(hObject, eventdata, handles) %try to minimize this.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});%


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
    %%
    a = 100;
    val_a = [0 a 0 0];
    
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
    
    %     val_b = [0 -a 0 a];
    %     set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
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
    %%
    a = 100;
    val_a = [0 -a 0 0];
    
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
    
    %     val_b = [0 a 0 -a];
    %     set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
end
%%
set(handles.uipanelb,'Units','normalized');
posy = get(handles.uipanelb,'Position');
set(handles.bb_slider,'Max',posy(4)-1);
set(handles.bb_slider,'Value',0);
set(handles.uipanelb,'Units','normalized');
gpos = get(handles.uipanelb,'Position');
gpos(2)= 0;
display(gpos);
set(handles.uipanelb,'Position',gpos);
set(handles.uipanelb,'Units','pixels');
function bot_extrad_CreateFcn(hObject, eventdata, handles) %try to minimize this.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});%


if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Yes','No'});

%--------YES/NO Visibility-------------------------------------
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

%% TOP Boundaries ===========================================================================

%% List Box ------------try to minimize-------------------------------------------------------------------------------------------
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

%% ==================ADD and REMOVE BUTTONS======================================================================================
%% removes most recent gas input boxes on bottom Mass Transport
function bot_mt_add_Callback(hObject, eventdata, handles)
uicontrol_1 = str2double(get(handles.CounterB,'String')); %calls value from counter
if lt(uicontrol_1,size(get(handles.bot_masstrans_2,'String'),1)) %if the counter is less than the amount of components
    set(handles.CounterB,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterB,'String')))+1)))); %add 1 to counter
    positiony = -24 * uicontrol_1; %multiply to increase the position avoids overlapping
    uicontrol_1 = str2double(get(handles.CounterB,'String'));
    
    % creates listbox and textbox for mass transport
    uicontrol('Parent',handles.uipanelb,'Style', 'popup',...
        'String',(get(handles.bot_masstrans_2,'String')),...
        'Position',(get(handles.bot_masstrans_2,'Position'))+[0 positiony 0 0],...
        'Tag',sprintf('bot_masstrans_2_%d',int32(uicontrol_1)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'popup',... % findobj('Tag','uipnelb') = handles.uipanelb
        'String',(get(handles.bot_masstrans_3,'String')),...
        'Position',(get(handles.bot_masstrans_3,'Position'))+[0 positiony 0 0],...
        'Tag',sprintf('bot_masstrans_3_%d',int32(uicontrol_1)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'edit',...
        'String','0','Position',(get(handles.bot_masstrans_4,'Position'))+[0 positiony+2 0 0],...
        'Tag',sprintf('bot_masstrans_4_%d',int32(uicontrol_1)),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style', 'edit',...
        'String','0','Position',(get(handles.bot_masstrans_5,'Position'))+[0 positiony+2 0 0],...
        'Tag',sprintf('bot_masstrans_5_%d',int32(uicontrol_1)),'Visible','on'); %'Callback', @setmap,
    
    %% Positions
    
    % item gets pushed down once inputs are created
    a = 25;
    val_a = [0 -a 0 0];
    val_c = [0 23.8-a 0 0];
    set(handles.text97,'Position',(get(handles.text97,'Position')-(val_a)));
    set(handles.bot_masstrans_1,'Position',(get(handles.bot_masstrans_1,'Position')-(val_a)));
    set(handles.bot_masstrans_2,'Position',(get(handles.bot_masstrans_2','Position')-(val_a)));
    set(handles.bot_masstrans_3,'Position',(get(handles.bot_masstrans_3','Position')-(val_a)));
    set(handles.bot_masstrans_4,'Position',(get(handles.bot_masstrans_4','Position')-(val_a)));
    set(handles.bot_masstrans_5,'Position',(get(handles.bot_masstrans_5','Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_c)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_c)));
    
    for j = 2:(uicontrol_1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 -a 0 a];
    set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
    %%
    set(handles.uipanelb,'Units','normalized');
    posy = get(handles.uipanelb,'Position');
    set(handles.bb_slider,'Max',posy(4)-1);
    set(handles.bb_slider,'Value',posy(4)-1);
    set(handles.uipanelb,'Units','normalized');
    gpos = get(handles.uipanelb,'Position');
    gpos(2)= -(posy(4)-1);
    display(gpos);
    set(handles.uipanelb,'Position',gpos);
    set(handles.uipanelb,'Units','pixels');
end

%% removes most recent gas input boxes on bottom Mass Transport
function bot_mt_rem_Callback(hObject, eventdata, handles)
uicontrol_1 = str2double(get(handles.CounterB,'String'));
if gt(uicontrol_1,1)
    
    uicontrol_1 = str2double(get(handles.CounterB,'String'));
    set(handles.CounterB,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterB,'String')))-1))));
    
    bot_masstrans_2 = findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(uicontrol_1))));
    bot_masstrans_3 = findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(uicontrol_1))));
    bot_masstrans_4 = findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(uicontrol_1))));
    bot_masstrans_5 = findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(uicontrol_1))));
    
    delete(bot_masstrans_2);
    delete(bot_masstrans_3);
    delete(bot_masstrans_4);
    delete(bot_masstrans_5);
    
    %%
    a = 25;
    val_a = [0 a 0 0];
    val_c = [0 a-23.8 0 0];
    set(handles.text97,'Position',(get(handles.text97,'Position')-(val_a)));
    set(handles.bot_masstrans_1,'Position',(get(handles.bot_masstrans_1,'Position')-(val_a)));
    set(handles.bot_masstrans_2,'Position',(get(handles.bot_masstrans_2,'Position')-(val_a)));
    set(handles.bot_masstrans_3,'Position',(get(handles.bot_masstrans_3,'Position')-(val_a)));
    set(handles.bot_masstrans_4,'Position',(get(handles.bot_masstrans_4,'Position')-(val_a)));
    set(handles.bot_masstrans_5,'Position',(get(handles.bot_masstrans_5,'Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_c)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_c)));
    
    for j = 2:(uicontrol_1-1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 a 0 -a];
    set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
    
    %%
    set(handles.uipanelb,'Units','normalized');
    posy = get(handles.uipanelb,'Position');
    set(handles.bb_slider,'Max',posy(4)-1);
    set(handles.bb_slider,'Value',posy(4)-1);
    set(handles.uipanelb,'Units','normalized');
    gpos = get(handles.uipanelb,'Position');
    gpos(2)= -(posy(4)-1);
    display(gpos);
    set(handles.uipanelb,'Position',gpos);
    set(handles.uipanelb,'Units','pixels');
end

%% adds gas input boxes on Bot Ignition Mass Fluxes
function bot_imf_add_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterC,'String'));
uicontrol_1 = str2double(get(handles.CounterB,'String'));%calls value from counter
if lt(uicontrol_2,size(get(handles.bot_masstrans_2,'String'),1))
    set(handles.CounterC,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterC,'String')))+1))));
    positiony = -24 * uicontrol_2;
    uicontrol_2 = str2double(get(handles.CounterC,'String'));
    
    handle1 = sprintf('bot_igntmassflux_1_%d',int32(uicontrol_2));
    handle2 = sprintf('bot_igntmassflux_2_%d',int32(uicontrol_2));
    
    uicontrol('Parent',handles.uipanelb,'Style','popup',...
        'String',(get(handles.bot_masstrans_2,'String')),...
        'Position',(get(handles.bot_igntmassflux_1,'Position'))+[0 positiony 0 0],...
        'Tag',handle1,'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelb,'Style','edit',...
        'String','0','Position',(get(handles.bot_igntmassflux_2,'Position'))+[0 positiony+2 0 0],...
        'Tag',handle2,'Visible','on'); %'Callback', @setmap,
    
    %%
    % item gets pushed down once inputs are created
    a = 25;
    val_a = [0 -a 0 0];
    
    set(handles.text97,'Position',(get(handles.text97,'Position')-(val_a)));
    set(handles.bot_masstrans_1,'Position',(get(handles.bot_masstrans_1,'Position')-(val_a)));
    set(handles.bot_masstrans_2,'Position',(get(handles.bot_masstrans_2','Position')-(val_a)));
    set(handles.bot_masstrans_3,'Position',(get(handles.bot_masstrans_3','Position')-(val_a)));
    set(handles.bot_masstrans_4,'Position',(get(handles.bot_masstrans_4','Position')-(val_a)));
    set(handles.bot_masstrans_5,'Position',(get(handles.bot_masstrans_5','Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_a)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_a)));
    
    for j = 2:(uicontrol_1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
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
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 -a 0 a];
    set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
    
    %%
    set(handles.uipanelb,'Units','normalized');
    posy = get(handles.uipanelb,'Position');
    set(handles.bb_slider,'Max',posy(4)-1);
    set(handles.bb_slider,'Value',0);
    set(handles.uipanelb,'Units','normalized');
    gpos = get(handles.uipanelb,'Position');
    gpos(2)= 0;
    display(gpos);
    set(handles.uipanelb,'Position',gpos);
    set(handles.uipanelb,'Units','pixels');
end

%% removes most recent gas input boxes on bottom Ignition Mass Fluxes
function bot_imf_rem_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterC,'String'));
uicontrol_1 = str2double(get(handles.CounterB,'String'));

if gt(uicontrol_2,1)
    
    uicontrol_2 = str2double(get(handles.CounterC,'String'));
    set(handles.CounterC,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterC,'String')))-1))));
    
    bot_igntmassflux_1 = findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(uicontrol_2))));
    bot_igntmassflux_2 = findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(uicontrol_2))));
    
    delete(bot_igntmassflux_1);
    delete(bot_igntmassflux_2);
    
    %%
    % item gets pushed down once inputs are created
    a = 25;
    val_a = [0 a 0 0];
    set(handles.text97,'Position',(get(handles.text97,'Position')-(val_a)));
    set(handles.bot_masstrans_1,'Position',(get(handles.bot_masstrans_1,'Position')-(val_a)));
    set(handles.bot_masstrans_2,'Position',(get(handles.bot_masstrans_2','Position')-(val_a)));
    set(handles.bot_masstrans_3,'Position',(get(handles.bot_masstrans_3','Position')-(val_a)));
    set(handles.bot_masstrans_4,'Position',(get(handles.bot_masstrans_4','Position')-(val_a)));
    set(handles.bot_masstrans_5,'Position',(get(handles.bot_masstrans_5','Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_a)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_a)));
    
    for j = 2:(uicontrol_1-1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
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
    
    for j = 2:(uicontrol_2-1)
        set(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_1_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('bot_igntmassflux_2_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 a 0 -a];
    set(handles.uipanelb,'Position',(get(handles.uipanelb,'Position')+(val_b)));
    
    %%
    set(handles.uipanelb,'Units','normalized');
    posy = get(handles.uipanelb,'Position');
    set(handles.bb_slider,'Max',posy(4)-1);
    set(handles.bb_slider,'Value',0);
    set(handles.uipanelb,'Units','normalized');
    gpos = get(handles.uipanelb,'Position');
    gpos(2)= 0;
    display(gpos);
    set(handles.uipanelb,'Position',gpos);
    set(handles.uipanelb,'Units','pixels');
end

%% adds gas input boxes on Mass Transport
function top_mt_add_Callback(hObject, eventdata, handles)
uicontrol_1 = str2double(get(handles.CounterD,'String'));
if lt(uicontrol_1,size(get(handles.top_masstrans_2,'String'),1))
    set(handles.CounterD,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterD,'String')))+1))));
    positiony = -24 * uicontrol_1;
    uicontrol_1 = str2double(get(handles.CounterD,'String'));
    
    uicontrol('Parent',handles.uipanelt,'Style', 'popup',...
        'String',(get(handles.top_masstrans_2,'String')),...
        'Position',(get(handles.top_masstrans_2,'Position'))+[0 positiony 0 0],...
        'Tag',(sprintf('top_masstrans_2_%d',int32(uicontrol_1))),...
        'Visible','on');
    
    uicontrol('Parent',handles.uipanelt,'Style', 'popup',...
        'String',(get(handles.top_masstrans_3,'String')),...
        'Position',(get(handles.top_masstrans_3,'Position'))+[0 positiony 0 0],...
        'Tag',(sprintf('top_masstrans_3_%d',int32(uicontrol_1))),...
        'Visible','on');
    
    uicontrol('Parent',handles.uipanelt,'Style', 'edit',...
        'String','0','Position',(get(handles.top_masstrans_4,'Position'))+[0 positiony+2 0 0],...
        'Tag',(sprintf('top_masstrans_4_%d',int32(uicontrol_1))),...
        'Visible','on');
    
    uicontrol('Parent',handles.uipanelt,'Style', 'edit',...
        'String','0','Position',(get(handles.top_masstrans_5,'Position'))+[0 positiony+2 0 0],...
        'Tag',(sprintf('top_masstrans_5_%d',int32(uicontrol_1))),...
        'Visible','on');
    
    %%
    a = 25;
    val_a = [0 -a 0 0];
    val_c = [0 23.8-a 0 0];
    set(handles.text45,'Position',(get(handles.text45,'Position')-(val_a)));
    set(handles.top_masstrans_1,'Position',(get(handles.top_masstrans_1,'Position')-(val_a)));
    set(handles.top_masstrans_2,'Position',(get(handles.top_masstrans_2','Position')-(val_a)));
    set(handles.top_masstrans_3,'Position',(get(handles.top_masstrans_3','Position')-(val_a)));
    set(handles.top_masstrans_4,'Position',(get(handles.top_masstrans_4','Position')-(val_a)));
    set(handles.top_masstrans_5,'Position',(get(handles.top_masstrans_5','Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_c)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_c)));
    
    for j = 2:(uicontrol_1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 -a 0 a];
    set(handles.uipanelt,'Position',(get(handles.uipanelt,'Position')+(val_b)));
    %%
    set(handles.uipanelt,'Units','normalized');
    posy = get(handles.uipanelt,'Position');
    set(handles.tb_slider,'Max',posy(4)-1);
    set(handles.tb_slider,'Value',posy(4)-1);
    set(handles.uipanelt,'Units','normalized');
    gpos = get(handles.uipanelt,'Position');
    gpos(2)= -(posy(4)-1);
    display(gpos);
    set(handles.uipanelt,'Position',gpos);
    set(handles.uipanelt,'Units','pixels');
end

%% removes most recent gas input boxes on top Mass Transport
function top_mt_rem_Callback(hObject, eventdata, handles)
uicontrol_1 = str2double(get(handles.CounterD,'String'));
if gt(uicontrol_1,1)
    
    uicontrol_1 = str2double(get(handles.CounterD,'String'));
    set(handles.CounterD,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterD,'String')))-1))));
    
    top_masstrans_2 = findobj('Tag',(sprintf('top_masstrans_2_%d',int32(uicontrol_1))));
    top_masstrans_3 = findobj('Tag',(sprintf('top_masstrans_3_%d',int32(uicontrol_1))));
    top_masstrans_4 = findobj('Tag',(sprintf('top_masstrans_4_%d',int32(uicontrol_1))));
    top_masstrans_5 = findobj('Tag',(sprintf('top_masstrans_5_%d',int32(uicontrol_1))));
    
    delete(top_masstrans_2);
    delete(top_masstrans_3);
    delete(top_masstrans_4);
    delete(top_masstrans_5);
    
    %%
    a = 25;
    val_a = [0 a 0 0];
    val_c = [0 a-23.8 0 0];
    set(handles.text45,'Position',(get(handles.text45,'Position')-(val_a)));
    set(handles.top_masstrans_1,'Position',(get(handles.top_masstrans_1,'Position')-(val_a)));
    set(handles.top_masstrans_2,'Position',(get(handles.top_masstrans_2','Position')-(val_a)));
    set(handles.top_masstrans_3,'Position',(get(handles.top_masstrans_3','Position')-(val_a)));
    set(handles.top_masstrans_4,'Position',(get(handles.top_masstrans_4','Position')-(val_a)));
    set(handles.top_masstrans_5,'Position',(get(handles.top_masstrans_5','Position')-(val_a)));
    set(handles.bot_mt_add,'Position', (get(handles.bot_mt_add,'Position')-(val_c)));
    set(handles.bot_mt_rem,'Position', (get(handles.bot_mt_rem,'Position')-(val_c)));
    
    for j = 2:(uicontrol_1-1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
    val_b = [0 a 0 -a];
    set(handles.uipanelt,'Position',(get(handles.uipanelt,'Position')+(val_b)));
    
    %%
    set(handles.uipanelt,'Units','normalized');
    posy = get(handles.uipanelt,'Position');
    set(handles.tb_slider,'Max',posy(4)-1);
    set(handles.tb_slider,'Value',posy(4)-1);
    set(handles.uipanelt,'Units','normalized');
    gpos = get(handles.uipanelt,'Position');
    gpos(2)= -(posy(4)-1);
    display(gpos);
    set(handles.uipanelt,'Position',gpos);
    set(handles.uipanelt,'Units','pixels');
end

%% adds gas input boxes on Top Ignition Mass Fluxes
function top_imf_add_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterE,'String'));
uicontrol_1 = str2double(get(handles.CounterD,'String'));

if lt(uicontrol_2,size(get(handles.top_masstrans_2,'String'),1))
    set(handles.CounterE,'String',...
        (sprintf('%d',int32((str2double(get(handles.CounterE,'String')))+1))));
    positiony = -24 * uicontrol_2;
    uicontrol_2 = str2double(get(handles.CounterE,'String'));
    
    uicontrol('Parent',handles.uipanelt,'Style','popup',...
        'String',(get(handles.top_masstrans_2,'String')),...
        'Position',(get(handles.top_igntmassflux_1,'Position'))+[0 positiony 0 0],...
        'Tag',(sprintf('top_igntmassflux_1_%d',int32(uicontrol_2))),'Visible','on'); %'Callback', @setmap,
    
    uicontrol('Parent',handles.uipanelt,'Style','edit',...
        'String','0','Position',(get(handles.top_igntmassflux_2,'Position'))+[0 positiony+2 0 0],...
        'Tag',(sprintf('top_igntmassflux_2_%d',int32(uicontrol_2))),'Visible','on'); %'Callback', @setmap,
    
    %%
    a = 25;
    val_a = [0 -a 0 0];
    
    set(handles.text45,'Position',(get(handles.text45,'Position')-(val_a)));
    set(handles.top_masstrans_1,'Position',(get(handles.top_masstrans_1,'Position')-(val_a)));
    set(handles.top_masstrans_2,'Position',(get(handles.top_masstrans_2','Position')-(val_a)));
    set(handles.top_masstrans_3,'Position',(get(handles.top_masstrans_3','Position')-(val_a)));
    set(handles.top_masstrans_4,'Position',(get(handles.top_masstrans_4','Position')-(val_a)));
    set(handles.top_masstrans_5,'Position',(get(handles.top_masstrans_5','Position')-(val_a)));
    set(handles.top_mt_add,'Position', (get(handles.top_mt_add,'Position')-(val_a)));
    set(handles.top_mt_rem,'Position', (get(handles.top_mt_rem,'Position')-(val_a)));
    
    for j = 2:(uicontrol_1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
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
    
    for j = 2:uicontrol_2
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));
    end
    
    val_b = [0 -a 0 a];
    set(handles.uipanelt,'Position',(get(handles.uipanelt,'Position')+(val_b)));
    
    %%
    set(handles.uipanelt,'Units','normalized');
    posy = get(handles.uipanelt,'Position');
    set(handles.tb_slider,'Max',posy(4)-1);
    set(handles.tb_slider,'Value',0);
    set(handles.uipanelt,'Units','normalized');
    gpos = get(handles.uipanelt,'Position');
    gpos(2)= 0;
    display(gpos);
    set(handles.uipanelt,'Position',gpos);
    set(handles.uipanelt,'Units','pixels');
end

%% removes most recent gas input boxes on Top Ignition Mass Fluxes
function top_imf_rem_Callback(hObject, eventdata, handles)
uicontrol_2 = str2double(get(handles.CounterE,'String'));
uicontrol_1 = str2double(get(handles.CounterD,'String'));

if gt(uicontrol_2,1)
    uicontrol_2 = str2double(get(handles.CounterE,'String'));
    set(handles.CounterE,'String',...
        (sprintf('%d',(int32(str2double(get(handles.CounterE,'String')))-1))));
    
    top_igntmassflux_1 = findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(uicontrol_2))));
    top_igntmassflux_2 = findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(uicontrol_2))));
    
    delete(top_igntmassflux_1);
    delete(top_igntmassflux_2);
    
    %%
    a = 25;
    val_a = [0 a 0 0];
    
    set(handles.text45,'Position',(get(handles.text45,'Position')-(val_a)));
    set(handles.top_masstrans_1,'Position',(get(handles.top_masstrans_1,'Position')-(val_a)));
    set(handles.top_masstrans_2,'Position',(get(handles.top_masstrans_2','Position')-(val_a)));
    set(handles.top_masstrans_3,'Position',(get(handles.top_masstrans_3','Position')-(val_a)));
    set(handles.top_masstrans_4,'Position',(get(handles.top_masstrans_4','Position')-(val_a)));
    set(handles.top_masstrans_5,'Position',(get(handles.top_masstrans_5','Position')-(val_a)));
    set(handles.top_mt_add,'Position', (get(handles.top_mt_add,'Position')-(val_a)));
    set(handles.top_mt_rem,'Position', (get(handles.top_mt_rem,'Position')-(val_a)));
    
    for j = 2:(uicontrol_1-1) %loop which shifts programatically made interface
        set(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_2_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_3_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_4_%d',int32(j))))','Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_masstrans_5_%d',int32(j))))','Position')-(val_a)));
    end
    
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
    %     set(handles.top_imf_add,'Position', (get(handles.top_imf_add,'Position')-(val_a)));
    %     set(handles.top_imf_rem,'Position', (get(handles.top_imf_rem,'Position')-(val_a)));
    
    for j = 2:(uicontrol_2-1)
        set(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_1_%d',int32(j)))),'Position')-(val_a)));
        set(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j))))','Position',...
            (get(findobj('Tag',(sprintf('top_igntmassflux_2_%d',int32(j)))),'Position')-(val_a)));
    end
    
    val_b = [0 a 0 -a];
    set(handles.uipanelt,'Position',(get(handles.uipanelt,'Position')+(val_b)));
    
    %%
    set(handles.uipanelt,'Units','normalized');
    posy = get(handles.uipanelt,'Position');
    set(handles.tb_slider,'Max',posy(4)-1);
    set(handles.tb_slider,'Value',0);
    set(handles.uipanelt,'Units','normalized');
    gpos = get(handles.uipanelt,'Position');
    gpos(2)= 0;
    display(gpos);
    set(handles.uipanelt,'Position',gpos);
    set(handles.uipanelt,'Units','pixels');
end

%% allow scrolling for Top boundary when information overlaps.
function bb_slider_Callback(hObject, eventdata, handles)
set(handles.uipanelb,'Units','normalized');
gpos = get(handles.uipanelb,'Position');
sval = get(handles.bb_slider,'Value');
gpos(2)= -sval;
display(gpos);
set(handles.uipanelb,'Position',gpos);
set(handles.uipanelb,'Units','pixels');

%% allow scrolling for Top boundary when information overlaps.
function tb_slider_Callback(hObject, eventdata, handles)
set(handles.uipanelt,'Units','normalized');
gpos = get(handles.uipanelt,'Position');
sval = get(handles.tb_slider,'Value');
gpos(2)= -sval;
display(gpos);
set(handles.uipanelt,'Position',gpos);
set(handles.uipanelt,'Units','pixels');














%% =================================OBJECT STRUCTURE===============================================================================

function OB_structpush_Callback(hObject, eventdata, handles)
% F=findobj('Tag','OBStructFig');
% if exist F==false
%Create Object Structure Figure
F = figure('Visible','on','Position',[680,280,270,170],'Resize','Off',...
    'MenuBar','none','Name','Object Structure','tag','OBStructFig');

%Create Panel with all content
L = uipanel('Parent',F,'Tag','Lpanel',...
    'Units','pixels','Position',[0 0 255 150],'BorderType','none');

%Create Panel that hold title
OST = uipanel('Parent',F,'Tag','TTpanel','Units','pixels',...
    'Position',[0 150 270 25],'BorderType','none');
%Create title
T = uicontrol('Parent',OST,'Style','text','HorizontalAlignment','center',...
    'String','Object Structure','FontSize',15,'FontWeight','bold',...
    'Units','pixels','Position',[60 0 185 25]);

%Creates Add Layer button
addlayer = uicontrol('Parent',L,'Style','pushbutton','String','+',...
    'Units','pixels','Position',[150 75 35 35],'Tag','add_layer',... %[215 90 35 35] side position
    'FontSize',20.0,'FontWeight','bold','Callback',@add_layer_Callback);
addlayert = uicontrol('Parent',L,'Style','text','Tag','add_layert',...
    'String','Add new layer','FontSize',10,...
    'Units','pixels','Position',[50 85 100 15]);

%Creates Remove Layer Button
remlayer = uicontrol('Parent',L,'Style','pushbutton','String','-',...
    'Units','pixels','Position',[215 50 35 35],'Tag','remove_layer',...
    'FontSize',20,'FontWeight','bold','Visible','Off','Callback',@remove_layer_Callback);

%Creates create Object structure button
createos = uicontrol('Parent',L,'Style','pushbutton','String','Create Object',...
    'Units','pixels','Position',[55 5 150 30],'Tag','create_os',...
    'FontSize',10,'Visible','Off','Callback',@layer_create_Callback);

global vscrollos
%Create scrollbar for moving content in figure
vscrollos = uicontrol('Parent',F,'Style','slider','Callback',@v_scrollos_Callback,...
    'Units','pixels','Position',[255 0 15 170],'Tag','v_scrollos','Visible','On');

addlistener(vscrollos,'Value','PreSet',... % allows scroll to update immediately
    @(hObject, eventdata)v_scrollos_Callback(hObject, eventdata, handles));

%Counter to determine number of layers
uicontrol('Style','text','String','0','Tag','Lcounter','Visible','Off');
%Holds ID of active layer
uicontrol('Style','text','String','0','Tag','CurentLay','Visible','Off');
% elseif exist F==true
%     F.Visible = 'On';
% end

function add_layer_Callback(hObject, eventdata, handles)
%% For Referencing
F = findobj('Tag','OBStructFig'); %Change height until 3 layers/position of screen
OST = findobj('Tag','TTpanel'); %Move up corresponding to figure
L = findobj('Tag','Lpanel'); %Change height and position coreesponding to figure
addlayer = findobj('Tag','add_layer');
addlayert = findobj('Tag','add_layert');
remlayer = findobj('Tag','remove_layer');
createos = findobj('Tag','create_os');
CurentLay = findobj('Tag','CurentLay');
Lcounter = findobj('Tag','Lcounter');
cmpdata = findobj('Tag','cmphold');
vscrollos = findobj('Tag','v_scrollos');

if lt(str2double(Lcounter.String),1)
    addlayer.Position = [215 90 35 35];
    addlayert.Visible = 'Off';
    remlayer.Visible = 'On';
    createos.Visible = 'On';
end

Lcounter.String = str2double(Lcounter.String)+1;

disp(sprintf('Layer %s',Lcounter.String));
%% create new layer
h = uipanel('Parent',L,'Tag',sprintf('oslayer_%s',Lcounter.String),...
    'Units','pixels','Position',[5 35 210 120],...
    'Title',sprintf('Layer #%s',Lcounter.String),...
    'FontSize',12.0,'FontWeight','bold','TitlePosition','centertop');

countMF = uicontrol('Parent',h,'Style','text',...
    'String','0','Visible','Off',...
    'Tag',sprintf('countMF_%s',Lcounter.String));

countMF.String = str2double(countMF.String)+1;
disp(sprintf('Layer %s Mass Fraction Count is %s',Lcounter.String,countMF.String));

thickt = uicontrol('Parent',h,'Style','text',...
    'String','Thickness:','Units','pixels','Position',[10 77 60 15],...
    'Tag',sprintf('thickt_%s',Lcounter.String));

thick = uicontrol('Parent',h,'Style','edit',...
    'Units','pixels','Position',[80 75 60 20],...
    'Tag',sprintf('thick_%s',Lcounter.String));

tempt = uicontrol('Parent',h,'Style','text',...
    'String','Temperature:','Units','pixels',...
    'Position',[10 55 70 15],'Tag',sprintf('tempt_%s',Lcounter.String));

temp = uicontrol('Parent',h,'Style','edit',...
    'Units','pixels','Position',[80 52 60 20],...
    'Tag',sprintf('temp_%s',Lcounter.String));

massfract = uicontrol('Parent',h,'Style','text',...
    'String','Mass Fraction:','Units','pixels',... % Make plural if more than two??
    'Position',[10 30 80 15],'Tag',sprintf('massfract_%s',Lcounter.String));

massfrac1 = uicontrol('Parent',h,'Style','popupmenu','String',cmpdata.String,...
    'Units','pixels','Position',[10 10 95 20],...
    'Tag',sprintf('mass_frac1_%s_%s',Lcounter.String,countMF.String)); %'Callback', @setmap,

massfrac2 = uicontrol('Parent',h,'Style','edit','Units','pixels',...
    'Position',[110 8 50 21.5],...
    'Tag',sprintf('mass_frac2_%s_%s',Lcounter.String,countMF.String));

addmf = uicontrol('Parent',h,'Style','pushbutton','Units','pixels',...
    'String','+','Position',[162 7 20 24],...
    'Tag',sprintf('add_mf_%s',Lcounter.String),'Callback',@add_mf_X_Callback);

remmf = uicontrol('Parent',h,'Style','pushbutton','Units','pixels',...
    'String','-','Position',[182 7 20 24],'Callback',@rem_mf_X_Callback,...
    'Tag',sprintf('rem_mf_%s',Lcounter.String),'Visible','Off'); %Turn visibility when more than 2 MF
%% Positioning
if gt(str2double(Lcounter.String),1)
    x = 125;
    if le(str2double(Lcounter.String),4)
        F.Position = F.Position + [0 -x 0 x];
        vscrollos.Position = vscrollos.Position + [0 0 0 x];
        OST.Position = OST.Position + [0 x 0 0];
    end
    L.Position = L.Position + [0 0 0 x];
    for j = 1:(str2double(Lcounter.String)-1)
        h = findobj('Tag',sprintf('oslayer_%d',j));
        h.Position = h.Position + [0 x 0 0];
    end
end
%% scroll adjustments
L.Units = 'normalized';
vscrollos.Max = L.Position(4) -.85;
L.Units = 'pixels';
%% Testing
global addmfplus remmfplus
n = str2double(Lcounter.String);
addmfplus = gobjects(n,1);
for ii = 1:n
addmfplus(ii) = findobj('Tag',sprintf('add_mf_%d',ii));
end

n = str2double(Lcounter.String);
remmfplus = gobjects(n,1);
for ii = 1:n
remmfplus(ii) = findobj('Tag',sprintf('rem_mf_%d',ii));
end

function remove_layer_Callback(hObject, eventdata, handles)
%% For Referencing
F = findobj('Tag','OBStructFig'); %Change height until 3 layers/position of screen
OST = findobj('Tag','TTpanel'); %Move up corresponding to figure
L = findobj('Tag','Lpanel'); %Change height and position coreesponding to figure
addlayer = findobj('Tag','add_layer');
addlayert = findobj('Tag','add_layert');
remlayer = findobj('Tag','remove_layer');
createos = findobj('Tag','create_os');
CurentLay = findobj('Tag','CurentLay');
Lcounter = findobj('Tag','Lcounter');
cmpdata = findobj('Tag','cmphold');
vscrollos = findobj('Tag','v_scrollos');

countMF = findobj('Tag',sprintf('countMF_%s',Lcounter.String));
massfrac2 = findobj('Tag',sprintf('mass_frac2_%s_%s',Lcounter.String,countMF.String));
massfrac1 = findobj('Tag',sprintf('mass_frac1_%s_%s',Lcounter.String,countMF.String));
massfract = findobj('Tag',sprintf('massfract_%s',Lcounter.String));
temp = findobj('Tag',sprintf('temp_%s',Lcounter.String));
tempt = findobj('Tag',sprintf('tempt_%s',Lcounter.String));
thick = findobj('Tag',sprintf('thick_%s',Lcounter.String));
thickt = findobj('Tag',sprintf('thickt_%s',Lcounter.String));
h = findobj('Tag',sprintf('oslayer_%s',Lcounter.String));

remmf = findobj('Tag',sprintf('rem_mf_%s',Lcounter.String));
addmf = findobj('Tag',sprintf('add_mf_%s',Lcounter.String));
%% Positioning
if gt(((str2double(Lcounter.String))-1),0)
    x = h.Position(4);
    disp(x); 
    x = x+5;
    y = 125;
    if le(((str2double(Lcounter.String))-1),3)
        F.Position = F.Position - [0 -y 0 y];
        vscrollos.Position = vscrollos.Position - [0 0 0 y];
        OST.Position = OST.Position - [0 y 0 0];
    end
    L.Position = L.Position - [0 0 0 x];
    for j = 1:((str2double(Lcounter.String))-1)
        hp = findobj('Tag',sprintf('oslayer_%d',j));
        hp.Position = hp.Position - [0 x 0 0];
    end
end
%% delete recent layer
if gt(str2double(Lcounter.String),0)
    delete(countMF);
    delete(remmf);
    delete(addmf);
    delete(massfrac2);
    delete(massfrac1);
    delete(massfract);
    delete(temp);
    delete(tempt);
    delete(thick);
    delete(thickt);
    delete(h);
    
    Lcounter.String = str2double(Lcounter.String)-1;
    disp(sprintf('There are now %s Layers',Lcounter.String));
end
%if at one last layer, return back to initial position
if eq(str2double(Lcounter.String),0)
    addlayer.Position= [150 75 35 35];
    addlayert.Visible = 'On';
    remlayer.Visible = 'Off';
end
%% scroll adjustments
L.Units = 'normalized';
vscrollos.Max = L.Position(4) -.85;
L.Units = 'pixels';

function Thick_X_Callback(hObject, eventdata, handles)
function Temp_X_Callback(hObject, eventdata, handles)
function layer_create_Callback(hObject, eventdata, handles)
F = findobj('Tag','OBStructFig');
F.Visible = 'Off';

function add_mf_X_Callback(src, ~)
%% Identifying button before excuting
global addmfplus
idx = find(addmfplus==src);
disp(['Layer ' num2str(idx)])

%% Naming each object to later call them
F = findobj('Tag','OBStructFig'); %Change height until 3 layers/position of screen
OST = findobj('Tag','TTpanel'); %Move up corresponding to figure
L = findobj('Tag','Lpanel'); %Change height and position coreesponding to figure
addlayer = findobj('Tag','add_layer');
addlayert = findobj('Tag','add_layert');
remlayer = findobj('Tag','remove_layer');
createos = findobj('Tag','create_os');
CurentLay = findobj('Tag','CurentLay');
Lcounter = findobj('Tag','Lcounter');
cmpdata = findobj('Tag','cmphold');
vscrollos = findobj('Tag','v_scrollos');

countMF = findobj('Tag',sprintf('countMF_%d',idx));
massfract = findobj('Tag',sprintf('massfract_%d',idx));
temp = findobj('Tag',sprintf('temp_%d',idx));
tempt = findobj('Tag',sprintf('tempt_%d',idx));
thick = findobj('Tag',sprintf('thick_%d',idx));
thickt = findobj('Tag',sprintf('thickt_%d',idx));
h = findobj('Tag',sprintf('oslayer_%d',idx));
remmf = findobj('Tag',sprintf('rem_mf_%d',idx));
addmf = findobj('Tag',sprintf('add_mf_%d',idx));

countMF.String = str2double(countMF.String) + 1; % adds one to counter

if gt(str2double(countMF.String),1) %shows remove button when more than one entry
    remmf.Visible = 'On';
end
%% creates new mass fraction entry
uicontrol('Parent',h,'Style','popupmenu','String',cmpdata.String,...
    'Units','pixels','Position',[10 10 95 20],...
    'Tag',sprintf('mass_frac1_%d_%s',idx,countMF.String));

uicontrol('Parent',h,'Style','edit','Units','pixels',...
    'Position',[110 8 50 21.5],...
    'Tag',sprintf('mass_frac2_%d_%s',idx,countMF.String));

disp(sprintf('Layer %d has %s Mass Fractions',idx,countMF.String));
%% Positioning
a = 26.5;
% F.Position = F.Position + [0 0 0 a];
% vscrollos.Position = vscrollos.Position + [0 0 0 a];
% OST.Position = OST.Position + [0 a 0 0]; 
L.Position = L.Position + [0 0 0 a];


% addlayer.Position = addlayer.Position + [0 a 0 0];
% remlayer.Position = remlayer.Position + [0 a 0 0];
massfract.Position = massfract.Position + [0 a 0 0];
tempt.Position = tempt.Position + [0 a 0 0];
thick.Position = thick.Position + [0 a 0 0];
thickt.Position = thickt.Position + [0 a 0 0];
temp.Position = temp.Position + [0 a 0 0];

for j = 1:(str2double(countMF.String)-1)
massfrac2 = findobj('Tag',sprintf('mass_frac2_%d_%d',idx,j));
massfrac1 = findobj('Tag',sprintf('mass_frac1_%d_%d',idx,j));
massfrac1.Position = massfrac1.Position + [0 a 0 0];
massfrac2.Position = massfrac2.Position + [0 a 0 0];
end

if idx == str2double(Lcounter.String)
    idx = idx-1;
    h.Position = h.Position + [0 0 0 a];
    for j = 1:idx
        h = findobj('Tag',sprintf('oslayer_%d',j));
        h.Position = h.Position + [0 a 0 0];
    end
elseif lt(idx,str2double(Lcounter.String))
    h.Position = h.Position + [0 -a 0 a];
    for j = 1:idx
        h = findobj('Tag',sprintf('oslayer_%d',j));
        h.Position = h.Position + [0 a 0 0];
    end
end

%% scrolling adjustments
L.Units = 'normalized';
vscrollos.Max = L.Position(4) -.85;
L.Units = 'pixels';

function rem_mf_X_Callback(src, ~)
%% Identifying button before excuting
global remmfplus
idx = find(remmfplus==src);
disp(['Layer ' num2str(idx)])
%% Naming each object to later call them
F = findobj('Tag','OBStructFig'); %Change height until 3 layers/position of screen
OST = findobj('Tag','TTpanel'); %Move up corresponding to figure
L = findobj('Tag','Lpanel'); %Change height and position coreesponding to figure
addlayer = findobj('Tag','add_layer');
addlayert = findobj('Tag','add_layert');
remlayer = findobj('Tag','remove_layer');
createos = findobj('Tag','create_os');
CurentLay = findobj('Tag','CurentLay');
Lcounter = findobj('Tag','Lcounter');
cmpdata = findobj('Tag','cmphold');
vscrollos = findobj('Tag','v_scrollos');

countMF = findobj('Tag',sprintf('countMF_%d',idx));
massfract = findobj('Tag',sprintf('massfract_%d',idx));
temp = findobj('Tag',sprintf('temp_%d',idx));
tempt = findobj('Tag',sprintf('tempt_%d',idx));
thick = findobj('Tag',sprintf('thick_%d',idx));
thickt = findobj('Tag',sprintf('thickt_%d',idx));
h = findobj('Tag',sprintf('oslayer_%d',idx));
remmf = findobj('Tag',sprintf('rem_mf_%d',idx));
addmf = findobj('Tag',sprintf('add_mf_%d',idx));

massfrac1 = findobj('Tag',sprintf('mass_frac1_%d_%s',idx,countMF.String));
massfrac2 = findobj('Tag',sprintf('mass_frac2_%d_%s',idx,countMF.String));

countMF.String = str2double(countMF.String) - 1; % removes one to counter

if eq(str2double(countMF.String),1)
    remmf.Visible = 'Off';
end
%% deleting mass fraction entry
delete(massfrac1);
delete(massfrac2);
disp(sprintf('Layer %d has %s Mass Fractions',idx,countMF.String));
%% Positioning
a = 26.5;
% F.Position = F.Position - [0 0 0 a];
% vscrollos.Position = vscrollos.Position - [0 0 0 a];
% OST.Position = OST.Position - [0 a 0 0]; 
L.Position = L.Position - [0 0 0 a];

% addlayer.Position = addlayer.Position - [0 a 0 0];
% remlayer.Position = remlayer.Position - [0 a 0 0];
massfract.Position = massfract.Position - [0 a 0 0];
tempt.Position = tempt.Position - [0 a 0 0];
thick.Position = thick.Position - [0 a 0 0];
thickt.Position = thickt.Position - [0 a 0 0];
temp.Position = temp.Position - [0 a 0 0];

for j = 1:(str2double(countMF.String))
massfrac2 = findobj('Tag',sprintf('mass_frac2_%d_%d',idx,j));
massfrac1 = findobj('Tag',sprintf('mass_frac1_%d_%d',idx,j));
massfrac1.Position = massfrac1.Position - [0 a 0 0];
massfrac2.Position = massfrac2.Position - [0 a 0 0];
end

if idx == str2double(Lcounter.String)
    idx = idx-1;
    h.Position = h.Position - [0 0 0 a];
    for j = 1:idx
        h = findobj('Tag',sprintf('oslayer_%d',j));
        h.Position = h.Position - [0 a 0 0];
    end
elseif lt(idx,str2double(Lcounter.String))
    h.Position = h.Position - [0 -a 0 a];
    for j = 1:idx
        h = findobj('Tag',sprintf('oslayer_%d',j));
        h.Position = h.Position - [0 a 0 0];
    end
end
%% scrolling adjustments
L.Units = 'normalized';
vscrollos.Max = L.Position(4) -.85;
L.Units = 'pixels';

function v_scrollos_Callback(hObject, eventdata, handles)
L = findobj('Tag','Lpanel'); %Change height and position coreesponding to figure
global vscrollos

L.Units = 'normalized';
vscrollos.Max = L.Position(4) -.85;
gpos = L.Position;
sval = vscrollos.Value;
gpos(1,2) = -sval;
L.Position = gpos;
L.Units = 'pixels';


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
