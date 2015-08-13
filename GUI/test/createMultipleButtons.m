 function createMultipleButtons(n)
 L = linspace(0.1, 0.9, n+1);
 if n > 1
     d = 0.9*(L(2)-L(1)); % Leave a little gap between the buttons
 else
     d = 0.8;
 end
 for k = 1:n
     uicontrol('Style', 'Pushbutton', ...
               'Units', 'normalized', ...
               'Position', [0.1 L(k) 0.5 d], ...
               'Callback', @callbackFcn, ...
               'UserData', k, ...
               'String', sprintf('Button %d', k));
 end
 function callbackFcn(h, varargin)
 buttonNumber = h.UserData; % For releases prior to R2014b, use GET here
 fprintf('Button %d pressed!\n', buttonNumber);