clc
clear
%Input-------------------------------
% FILE_NAME='17.5x5burnerAug28_2014y25CEA180scool.txt';
tic
file_name = '17.5x5burnerAug28_2014y25CEA180scool_10s.txt';
fid = fopen(file_name,'rt');
C = textscan(fid,'%s','delimiter','\t');
fclose(fid);
 file_strings = C{1}(~cellfun('isempty',C{1}(:,1)),:); % Pretty sure this removes any blank lines in the .OUT file

%USER INPUT, select time (range) at which to display figures 
DISP_TIMESTEP=9;
start_time = 2;
end_time = 8;
DISP_HEAT_FLX_MIN=-5;
DISP_HEAT_FLX_MAX=40;
% FILTER_TARGET='PMMA_g';
%------------------------   ------------
numcomp=sscanf(file_strings{4},'%*s %*s %*s %u');
% disp(numcomp);
% Iwant = 'temp';
file_strings_sz=size(file_strings);

%------------ The Five Possible Plot Types------------
PLOTS=0*ones(5,1);

PLOT_temp_profile = 'on';%1
PLOT_conc_profile = 'off';%2
PLOT_heat_flux = 'off';%3
PLOT_heat_flux_mode = 'NET';% or 'Total Flame'
PLOT_MLR = 'off';%4
PLOT_Tempat_position = 'on';%5

if strcmp(PLOT_temp_profile,'on')
    PLOTS(1,1) = 1;
end

if strcmp(PLOT_conc_profile,'on')
    PLOTS(2,1) = 1;
end

if strcmp(PLOT_heat_flux,'on')
    PLOTS(3,1) = 1;
end

if strcmp(PLOT_MLR,'on')
    PLOTS(4,1) = 1;
end

if strcmp(PLOT_Tempat_position,'on')
    PLOTS(5,1) = 1;
end

%-----------Figure and SubPlot Sizing---------------
if sum(PLOTS(:,1))==0 
    disp('Please select a figure to display')

%Single Plot, Tall Rectangle        
elseif sum(PLOTS(1:3)) == 1 && sum(PLOTS(4:5)) == 0
    disp('Single Plot, Tall Rectangle ')
%Single Plot, Square
elseif sum(PLOTS(1:3)) == 0 && sum(PLOTS(4:5)) == 1
    disp('Single Plot, Square')

%Two Plots, Two Tall Rectangles
elseif sum(PLOTS(1:3)) == 2 && sum(PLOTS(4:5)) == 0
    disp('Two Plots, Two Tall Rectangles')

%Two Plots, One Tall Rectangle and a Square
elseif sum(PLOTS(1:3)) == 1 && sum(PLOTS(4:5)) == 1
    disp('Two Plots, One Tall Rectangle and a Square')
%Three Plots, Two Tall Rectangles and a Square
elseif sum(PLOTS(1:3)) == 2 && sum(PLOTS(4:5)) == 1
    disp('Three Plots, Two Tall Rectangles and a Square')
%Three Plots, Three Tall Rectangles
elseif sum(PLOTS(1:3)) == 3 && sum(PLOTS(4:5)) == 0
    disp('Three Plots, Two Tall Rectangles and a Square')
else
    disp('Please choose a different combination of Figures (three of fewer)')
end


single_plots = 'on';
plots_over_time = 'off';
two_plots = 'on';
temp_vs_pos = 'off';
select_position_x =0.011875;
select_position_y =0.17375;
if select_position_y <= 0.175 && select_position_y >= 0 
    PLOT_Tempat_position = 'on';
end 

% if temp='on' && pos='on'
%     temp_vs_pos='on'
% end
temp_vs_MLR = 'on';
conc_vs_pos = 'off';
conc_vs_MLR = 'off';
%Index code from 1 to 5
%Options to turn on

trump3 = 'off';
trump2 = 'off';
smooth_shading = 200;
colormap(jet);
%end of selections

%End of Options

%godNum from 1 to 8
Component_selected_index = 6;% USER INPUT Chooses the index of the component that will be plotted as a composition profile
i=0;
time_iy = 0;
while i < file_strings_sz(1,1)
    i = i+1;
    if strcmp(file_strings{i}, 'Time [s] =')
        count_height = 1;%0
        time_iy = time_iy+1;
        time_hold(time_iy,1) = str2double(file_strings{i+1});
    end 
   if strcmp(file_strings{i}, 'MASS FLOW OUT [kg/s]:') && time_iy == 1
        disp('good');
        j= 1;
        i = i+1;
        while j < numcomp
            Components{j,1} = file_strings{i};
            i = i+1;
            j = j+1;
        end 
    end 
    if strcmp(file_strings{i}, 'Total length [m]  =')
        i = i+1;
        total_length = str2double(file_strings{i});
        n_counter = 0;
        count_height = count_height+1;
        while n_counter < count2
            n_counter = n_counter+1;
            xx(count_height, n_counter, time_iy) = xx(count_height-1,n_counter, time_iy);
            yy(count_height, n_counter,time_iy) = str2double(file_strings{i});
            temp(count_height, n_counter,time_iy) = temp(count_height-1,n_counter,time_iy);%0
            hflux(count_height, time_iy) = hflux(count_height-1,time_iy)/1000;
            conc(count_height, n_counter,time_iy)= conc(count_height-1,n_counter,time_iy);%0
        end 
    end 
    if strcmp(file_strings{i}, 'Total mass [kg/m] =')
        mass(time_iy,1) = str2double(file_strings{i+1});
    end 
    if strcmp(file_strings{i}, 'FROM BOTTOM [m] =')
        count_height = count_height+1;
        i = i+1;
        val = str2double(file_strings{i});
        val2 = str2double(file_strings{i+2});
        hflux(count_height, time_iy) = val2/1000;
        while ~strcmp(file_strings{i}, 'FROM BACK [m]') 
            i = i+1;
        end 
%         count1_back = count1_back+1;
        count2 = 0;
        i = i+11;
        count2 = count2+1;
        
        xx(count_height, count2, time_iy) = str2double(file_strings{i});

        yy(count_height, count2,time_iy) = val;
        temp(count_height,count2, time_iy) = str2double(file_strings{i+1});
        conc(count_height, count2, time_iy) = str2double(file_strings{i+1+Component_selected_index});
        concIndex(count_height, count2, time_iy) = i+1+Component_selected_index; 
        while ~strcmp(file_strings{i+10}, '-----------------------------')
            count2 = count2+1;
            i = i+10;
            xx(count_height, count2, time_iy) = str2double(file_strings{i});
            xx_index(count_height, count2,time_iy) = i;
            yy(count_height, count2, time_iy) = val;
            temp(count_height,count2, time_iy) = str2double(file_strings{i+1});
            conc(count_height, count2, time_iy) = str2double(file_strings{i+1+Component_selected_index});
            concIndex(count_height, count2, time_iy) = i+1+Component_selected_index;
        end
        count2 = count2+1;
        xx(count_height, count2,time_iy) = 0;
        yy(count_height, count2,time_iy) = yy(count_height, count2-1,time_iy);
        temp(count_height, count2, time_iy) = 0;
        conc(count_height, count2, time_iy)= 0;
    end
    
end
change_boundary_y = 1;
while change_boundary_y < time_iy
    y_d = 1;
    while y_d < size(xx(1,:,1),2)
        xx(1,y_d,change_boundary_y) = xx(2,y_d,change_boundary_y);
        yy(1,y_d,change_boundary_y) = 0;
        temp(1,y_d,change_boundary_y) = temp(2,y_d,change_boundary_y);
        conc(1, y_d,change_boundary_y) = conc(2,y_d,change_boundary_y);
        y_d = y_d+1;
    end 
    change_boundary_y = change_boundary_y+1;
end 
Component_selected = Components{Component_selected_index,1};
count_time = 1;
reform_count1 = 1;
while count_time < 600
    max_conc_val(count_time,1)= max(max(conc(:,:,count_time)));
    count_time= count_time+1;
end 
real_max_conc = max(max_conc_val(:,1));
while reform_count1 < size(time_hold(:,1))
    int1 = 1;
    while int1 < size(conc(:,1,1))
        while int2 < size(conc(int1,:,reform_count1))
            conc(int1,int2,reform_count1) = (conc(int1,int2,reform_count1)/real_max_conc)*100;
        end 
        int1 = int1+1;
    end
    reform_count1 = reform_count1+1;
end 
% temp_vs_pos = 'on';
% temp_vs_MLR = 'on';
% conc_vs_pos = 'on';
% conc_vs_MLR = 'on';
warning = 1;
if strcmp(two_plots, 'on')
    
    if strcmp(temp_vs_pos, 'on')
        subplot(1,2,2);
        if (select_position_x <= 0.012 && select_position_x > 0)
            %specified time position 
            warning =0;
            tmp = abs(xx(1,:,1)-select_position_x);
            [idxA idxA] = min(tmp);
            tmp = abs(yy(:,1,1)-select_position_y);
            [idxB idxB] = min(tmp);
            %from start to end 
            disp(xx(1,idxA,1));
            disp(yy(idxB,1,1));
            disp(idxA);
            disp(idxB);
            temperature(:,1) = temp(idxB,idxA,:);
            plot(time_hold(:,1),temperature(:,1));
            xlim([0 600]);
            ylim([250 700]);
            title('Temperature over time at specific location');
            xlabel('Time [s]'); % x-axis label
            ylabel('Temperature [K]'); % y-axis label
        end 
        if warning == 0
            disp('Sorry, the positions you selected do not exist');
        end
    tmp = abs(time_hold(:,1)-start_time);
    [idxA idxA] = min(tmp);
    tmp = abs(time_hold(:,1)-end_time);
    [idxB idxB] = min(tmp);
    width = (count2*.016);
    height = count_height*.011643;
    % set(gca,'Position',[0.1145 0.11 width height]);
     while idxA < idxB
            subplot(1,3,1);
            contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),temp(:,:,time_hold(idxA,1)),100,'EdgeColor','none');
            set(gca,'Position',[0.1145 0.11 width height]);
            title('Temperature Profile');
            xlabel('From Back [m]'); % x-axis label
            ylabel('From Bottom [m]'); % y-axis label
            caxis([200 700]);
            colorbar;
            if time_hold(idxA,1) == 500
                print('ContourPlot','-dpng');
            end 
    %         start_time = time_hold(count_it,1)
            disp(time_hold(idxA,1));
             pause(0.08);
              idxA = idxA+1;
     end
    end 
    % temp_vs_MLR = 'on';
    if strcmp(temp_vs_MLR, 'on')
           x = 0;
            while x < 600
                x = x+1;
                mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
            end
            mlr(x+1,1) = mlr(x,1)*1000;
        %     disp(size(mlr(:,1)));
        %     disp(size(time_hold(:,1)));
        %     disp(temp(1,2,550));
            subplot(1,2,2);
            plot(time_hold(:,1), mlr(:,1));
            title('Mass Loss Rate Profile');
                xlim([0 700]);
                %0.001
            ylim([0 1]);
               xlabel('Time [s]'); % x-axis label
                ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
                tmp = abs(time_hold(:,1)-start_time);
    [idxA idxA] = min(tmp);
    tmp = abs(time_hold(:,1)-end_time);
    [idxB idxB] = min(tmp);
    width = (count2*.016);
    height = count_height*.011643;
    % set(gca,'Position',[0.1145 0.11 width height]);
     while idxA < idxB
            subplot(1,3,1);
            contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),temp(:,:,time_hold(idxA,1)),100,'EdgeColor','none');
            set(gca,'Position',[0.1145 0.11 width height]);
            title('Temperature Profile');
            xlabel('From Back [m]'); % x-axis label
            ylabel('From Bottom [m]'); % y-axis label
            caxis([200 700]);
            colorbar;
            if time_hold(idxA,1) == 500
                print('ContourPlot','-dpng');
            end 
    %         start_time = time_hold(count_it,1)
            disp(time_hold(idxA,1));
             pause(0.08);
              idxA = idxA+1;
     end
    end
    % conc_vs_pos = 'on';
% conc_vs_MLR = 'on';
    if strcmp(conc_vs_pos, 'on')
         subplot(1,2,2);
        if (select_position_x <= 0.012 && select_position_x > 0)
            %specified time position 
            warning =0;
            tmp = abs(xx(1,:,1)-select_position_x);
            [idxA idxA] = min(tmp);
            tmp = abs(yy(:,1,1)-select_position_y);
            [idxB idxB] = min(tmp);
            %from start to end 
            disp(xx(1,idxA,1));
            disp(yy(idxB,1,1));
            disp(idxA);
            disp(idxB);
            temperature(:,1) = temp(idxB,idxA,:);
            plot(time_hold(:,1),temperature(:,1));
            xlim([0 600]);
            ylim([250 700]);
            title('Temperature over time at specific location');
            xlabel('Time [s]'); % x-axis label
            ylabel('Temperature [K]'); % y-axis label
        end 
        if warning == 0
            disp('Sorry, the positions you selected do not exist');
        end
           tmp = abs(time_hold(:,1)-start_time);
        [idxA idxA] = min(tmp);
        % disp(start_time);
        tmp = abs(time_hold(:,1)-end_time);
        [idxB idxB] = min(tmp);
     while idxA < idxB
       
        contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),conc(:,:,time_hold(idxA,1)),smooth_shading,'EdgeColor','none');
%     shading flat;   
        title('Concentration Profile');
        xlabel('From Back [m]'); % x-axis label
        ylabel('From Bottom [m]'); % y-axis label
        caxis([0 100]);
        colorbar;
        disp(time_hold(idxA,1));
        idxA = idxA+1;
    end 
    end 
    if strcmp(conc_vs_MLR, 'on')
        x = 0;
        while x < 600
            x = x+1;
            mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
        end
            mlr(x+1,1) = mlr(x,1)*1000;
        %     disp(size(mlr(:,1)));
        %     disp(size(time_hold(:,1)));
        %     disp(temp(1,2,550));
            subplot(1,2,2);
            plot(time_hold(:,1), mlr(:,1));
            title('Mass Loss Rate Profile');
                xlim([0 700]);
                %0.001
            ylim([0 1]);
               xlabel('Time [s]'); % x-axis label
                ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
               tmp = abs(time_hold(:,1)-start_time);
        [idxA idxA] = min(tmp);
        % disp(start_time);
        tmp = abs(time_hold(:,1)-end_time);
        [idxB idxB] = min(tmp);
         while idxA < idxB
            subplot(1,2,1);
            contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),conc(:,:,time_hold(idxA,1)),smooth_shading,'EdgeColor','none');
    %     shading flat;   
            title('Concentration Profile');
            xlabel('From Back [m]'); % x-axis label
            ylabel('From Bottom [m]'); % y-axis label
            caxis([0 100]);
            colorbar;
            disp(time_hold(idxA,1));
            idxA = idxA+1;
        end     
    end 
end 
% disp(count2/count1_back);
% height = count1_back*.11643;
% disp(bottom(:,:,2));
%     0.1300    0.1100    0.7750    0.8150
% disp(back(:,:,myTime+1));
% set(gca,'Position',[0.1300 0.1100 0.21 0.8150]);
% disp(bflux(:, 1));
% disp(hflux(:,300));

% if strcmp(MLR, 'on')
%     x = 0;
%     while x < 600
%         x = x+1;
%         mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
%     end
%     mlr(x+1,1) = mlr(x,1)*1000;
% %     disp(size(mlr(:,1)));
% %     disp(size(time_hold(:,1)));
% %     disp(temp(1,2,550));
%      
%     plot(time_hold(:,1), mlr(:,1));
%     title('Mass Loss Rate Profile');
%         xlim([0 700]);
%         %0.001
%     ylim([0 1]);
%        xlabel('Time [s]'); % x-axis label
%         ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
% end
% 
% if strcmp(Tempat_position, 'on')
%     if ~(select_position_x <= 0.012 && select_position_x > 0)
%         disp('Sorry, the positions you selected do not exist');
%         break;
%     end 
%     %specified time position 
%     tmp = abs(xx(1,:,1)-select_position_x);
%     [idxA idxA] = min(tmp);
%     tmp = abs(yy(:,1,1)-select_position_y);
%     [idxB idxB] = min(tmp);
%     %from start to end 
%     disp(xx(1,idxA,1));
%     disp(yy(idxB,1,1));
%     disp(idxA);
%     disp(idxB);
%     temperature(:,1) = temp(idxB,idxA,:);
%     plot(time_hold(:,1),temperature(:,1));
%       xlim([0 600]);
%     ylim([250 700]);
%     title('Temperature over time at specific location');
%       xlabel('Time [s]'); % x-axis label
%         ylabel('Temperature [K]'); % y-axis label
% end 
% if strcmp(trump2, 'on')
%      x = 0;
%     while x < 600
%         x = x+1;
%         mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
%     end
%     mlr(x+1,1) = mlr(x,1)*1000;
% %     disp(size(mlr(:,1)));
% %     disp(size(time_hold(:,1)));
% %     disp(temp(1,2,550));
%      subplot(1,2,1);
%     plot(time_hold(:,1), mlr(:,1));
%     title('Mass Loss Rate Profile');
%         xlim([0 700]);
%         %0.001
%     ylim([0 1]);
%        xlabel('Time [s]'); % x-axis label
%         ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
%     if ~(select_position_x <= 0.012 && select_position_x > 0)
%         disp('Sorry, the positions you selected do not exist');
%         break;
%     end 
%      tmp = abs(xx(1,:,1)-select_position_x);
%     [idxA idxA] = min(tmp);
%     tmp = abs(yy(:,1,1)-select_position_y);
%     [idxB idxB] = min(tmp);
%     %from start to end 
%     disp(xx(1,idxA,1));
%     disp(yy(idxB,1,1));
%     disp(idxA);
%     disp(idxB);
%     temperature(:,1) = temp(idxB,idxA,:);
%     subplot(1,2,2);
%     plot(time_hold(:,1),temperature(:,1));
%       xlim([0 600]);
%     ylim([250 700]);
%     title('Temperature over time at specific location');
%       xlabel('Time [s]'); % x-axis label
%         ylabel('Temperature [K]'); % y-axis label
% end 
if strcmp(plots_over_time, 'on')
tmp = abs(time_hold(:,1)-start_time);
[idxA idxA] = min(tmp);
% disp(start_time);
tmp = abs(time_hold(:,1)-end_time);
[idxB idxB] = min(tmp);
width = count2*.016;
height = count_height*.011643;
set(gca,'Position',[0.1145 0.11 width height]);
% disp(end_time);
while idxA < idxB
    subplot(1,3,3);
    contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),conc(:,:,time_hold(idxA,1)),smooth_shading,'EdgeColor','none');
%     shading flat;   
    title('Concentration Profile');
        xlabel('From Back [m]'); % x-axis label
        ylabel('From Bottom [m]'); % y-axis label
        caxis([0 100]);
        colorbar;
        disp(time_hold(idxA,1));
         subplot(1,3,2);
    h = area(yy(:,1,1),hflux(:,time_hold(idxA,1)));
    xlim([0 total_length]);%0.18
    ylim([-15 35]);
    title('Heat Flux over time');
    xlabel('Height'); % x-axis label
    ylabel('Heat Flux In kW/m^2'); % y-axis label
    h.FaceColor = 'red';
    view(90,270);
     subplot(1,3,1);
        contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),temp(:,:,time_hold(idxA,1)),smooth_shading,'EdgeColor','none');
        shading flat;
%         set(gca,'Position',[0.1145 0.11 width height]);
        title('Temperature Profile');
        xlabel('From Back [m]'); % x-axis label
        ylabel('From Bottom [m]'); % y-axis label
        caxis([200 700]);
        colorbar;
        if time_hold(idxA,1) == 500
            print('ContourPlot','-dpng');
        end 
         pause(0.008);
    idxA = idxA+1;
end 
end 
%  Temp_profile = 'off';%1
% Conc_profile = 'on';%2
% Heat_flux = 'off';%3
% MLR = 'off';%4
% Tempat_position = 'off';%5

if strcmp(single_plots,'on')
    if strcmp(PLOT_Tempat_position, 'on')
    if ~(select_position_x <= 0.012 && select_position_x > 0)
        disp('Sorry, the positions you selected do not exist');
        return;
    end 
    %specified time position  
    tmp = abs(xx(1,:,1)-select_position_x);
    [idxA idxA] = min(tmp);
    tmp = abs(yy(:,1,1)-select_position_y);
    [idxB idxB] = min(tmp);
    %from start to end 
    disp(xx(1,idxA,1));
    disp(yy(idxB,1,1));
    disp(idxA);
    disp(idxB);
    temperature(:,1) = temp(idxB,idxA,:);
    plot(time_hold(:,1),temperature(:,1));
      xlim([0 600]);
    ylim([250 700]);
    title('Temperature over time at specific location');
      xlabel('Time [s]'); % x-axis label
        ylabel('Temperature [K]'); % y-axis label
    end 
     
    
    if strcmp(PLOT_MLR,'on')
            x = 0;
            while x < 600
                x = x+1;
                mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
            end
            mlr(x+1,1) = mlr(x,1)*1000;
        %     disp(size(mlr(:,1)));
        %     disp(size(time_hold(:,1)));
        %     disp(temp(1,2,550));

            plot(time_hold(:,1), mlr(:,1));
            title('Mass Loss Rate Profile');
                xlim([0 700]);
                %0.001
            ylim([0 1]);
               xlabel('Time [s]'); % x-axis label
                ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
    end 
    if strcmp(PLOT_conc_profile, 'on')
         tmp = abs(time_hold(:,1)-start_time);
        [idxA idxA] = min(tmp);
        % disp(start_time);
        tmp = abs(time_hold(:,1)-end_time);
        [idxB idxB] = min(tmp);
        width = (count2*.016);
    height = count_height*.011643;
    % set(gca,'Position',[0.1145 0.11 width height]);
     while idxA < idxB
        contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),conc(:,:,time_hold(idxA,1)),smooth_shading,'EdgeColor','none');
%     shading flat;   
        set(gca,'Position',[0.1145 0.11 width height]);
        title('Concentration Profile');
        xlabel('From Back [m]'); % x-axis label
        ylabel('From Bottom [m]'); % y-axis label
        caxis([0 100]);
        colorbar;
        disp(time_hold(idxA,1));
        pause(0.08);
        idxA = idxA+1;
    end 
    end 
    if strcmp(PLOT_heat_flux, 'on')
    tmp = abs(time_hold(:,1)-start_time);
    [idxA idxA] = min(tmp);
    % disp(start_time);
    tmp = abs(time_hold(:,1)-end_time);
    [idxB idxB] = min(tmp);
    % disp(end_time);
     while idxA < idxB
         subplot(1,3,2);
        h = area(yy(:,1,1),hflux(:,time_hold(idxA,1)));
        xlim([0 0.2]);
        ylim([-15 35]);
        title('Heat Flux over time');
        xlabel('Height'); % x-axis label
        ylabel('Heat Flux In W/m^2 * 1000'); % y-axis label
        h.FaceColor = 'red';
        view(90,270);
        pause(0.1);
        disp(time_hold(idxA,1));
        idxA= idxA+1;
     end
    end 
    
    if strcmp(PLOT_temp_profile,'on')
    tmp = abs(time_hold(:,1)-start_time);
    [idxA idxA] = min(tmp);
    tmp = abs(time_hold(:,1)-end_time);
    [idxB idxB] = min(tmp);
    width = (count2*.016);
    height = count_height*.011643;
    % set(gca,'Position',[0.1145 0.11 width height]);
     while idxA < idxB
            subplot(1,3,1);
            contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),temp(:,:,time_hold(idxA,1)),100,'EdgeColor','none');
            set(gca,'Position',[0.1145 0.11 width height]);
            title('Temperature Profile');
            xlabel('From Back [m]'); % x-axis label
            ylabel('From Bottom [m]'); % y-axis label
            caxis([200 700]);
            colorbar;
            if time_hold(idxA,1) == 500
                print('ContourPlot','-dpng');
            end 
    %         start_time = time_hold(count_it,1)
            disp(time_hold(idxA,1));
             pause(0.08);
              idxA = idxA+1;
     end
    end 
end 
toc


