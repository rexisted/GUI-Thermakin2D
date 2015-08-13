function lotsofbuttons
n = 3; %Whatever number of buttons
pbs = gobjects(n,1); % Store pushbuttons here
for ii = 1:n; %loop to create how ever many pushbuttons there are.
    pbs(ii) = uicontrol('Style','Pushbutton','String',sprintf('%d',3-ii),'Units','normalized','Position',rand(1,4)./2,'Callback',@TheCallback);
end
      function TheCallback(src,~) 
         idx = find(pbs==src); % Compare list to source
         disp(['Pushbutton ' num2str(idx)])
      end
end