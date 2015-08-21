function save_figure_perhaps
% Closes figure conditionally, asking whether to save it first.
% User can suppress the dialog from UIGETPREF permanently by selecting
% "Do not show this dialog again".

fig = gcf;
[selectedButton dlgshown] = uigetpref(...
    'mygraphics',...                        % Group
    'savefigurebeforeclosing',...           % Preference
    'Closing Figure',...                    % Window title
    {'Do you want to save your figure before closing?'
     ''
     'You can save your figure manually by typing ''hgsave(gcf)'''},...
    {'always','never';'Yes','No'},...        % Values and button strings
     'ExtraOptions','Cancel',...             % Additional button
     'DefaultButton','Cancel',...            % Default choice
     'HelpString','Help',...                 % String for Help button
     'HelpFcn','doc(''closereq'');');        % Callback for Help button
switch selectedButton
    case 'always'  % Open a Save dialog (without testing if saved before)
    [fileName,pathName,filterIndex] = uiputfile('fig', ...
                                  'Save current figure', ...
                                  'untitled.fig');
       if filterIndex == 0     % User cancelled save or named no file
           delete(fig);
       else                    % Use filename returned from UIPUTFILE
           saveas(fig,[pathName fileName])
           delete(fig);
       end
   case 'never'                % Close the figure without saving it
       delete(fig);
   case 'cancel'               % Do not close the figure
       return
 end