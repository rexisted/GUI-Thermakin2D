clc
clear
%Input-------------------------------
FILE_NAME='17.5x5burnerAug28_2014y25CEA180scool.txt';
tic
file_name = '17.5x5burnerAug28_2014y25CEA180scool_full_new.txt';
fid = fopen(file_name,'rt');
C = textscan(fid,'%s','delimiter','\t');
fclose(fid);
 file_strings = C{1}(~cellfun('isempty',C{1}(:,1)),:);
DISP_TIMESTEP=290;
DISP_HEAT_FLX_MIN=-5;
DISP_HEAT_FLX_MAX=40;
% FILTER_TARGET='PMMA_g';
%------------------------   ------------
numcomp=sscanf(file_strings{4},'%*s %*s %*s %u');
% disp(numcomp);
Iwant = 'temp';
file_strings_sz=size(file_strings);
file_strings_x=0;
myTime = 100;
count1_from_back = 0;
count1_from_bottom= 0;
count1_temp = 0;
file_strings_temp = 0;
time_iy = 0;
flux_count = 1;
start_time = 400;
end_time = 600;
%Options to turn on
Temp_profile = 'off';
Conc_profile = 'on';
Heat_flux = 'off';
MLR = 'off';
Tempat_position = 'off';
trump3 = 'off';
trump2 = 'off';
smooth_shading = 1;
if strcmp(Temp_profile, 'on')||strcmp(Conc_profile,'on')||strcmp(Heat_flux, 'on')
    trump3 = 'on';
end 
if strcmp(Tempat_position, 'on')||strcmp(MLR, 'on')
    trump2 = 'on';
end 
%end of selections
select_position_x =0.011875;
select_position_y =0.17375;
if select_position_y <= 0.175 && select_position_y >= 0 
    Tempat_position = 'on';
end 
%End of Options
%godNum from 1 to 8
godNum = 6;
%material choice 

while file_strings_x < file_strings_sz(1,1)
    file_strings_x = file_strings_x+1;
    if strcmp(file_strings{file_strings_x}, 'Time [s] =')
        count_height = 0;
        time_iy = time_iy+1;
        time_hold(time_iy,1) = str2double(file_strings{file_strings_x+1});
    end 
   if strcmp(file_strings{file_strings_x}, 'MASS FLOW OUT [kg/s]:') && time_iy == 1
        disp('good');
        m_count= 1;
        file_strings_x = file_strings_x+1;
        while m_count < numcomp
            material_hold{m_count,1} = file_strings{file_strings_x};
            file_strings_x = file_strings_x+1;
            m_count = m_count+1;
        end 
    end 
    if strcmp(file_strings{file_strings_x}, 'Total length [m]  =')
        file_strings_x = file_strings_x+1;
        n_counter = 0;
        count_height = count_height+1;
        while n_counter < count2
            n_counter = n_counter+1;
            xx(count_height, n_counter, time_iy) = xx(count_height-1,n_counter, time_iy);
            yy(count_height, n_counter,time_iy) = str2double(file_strings{file_strings_x});
            temp(count_height, n_counter,time_iy) = 0;
            hflux(count_height, time_iy) = hflux(count_height-1,time_iy)/1000;
            conc(count_height, n_counter,time_iy)= 0;
        end 
    end 
    if strcmp(file_strings{file_strings_x}, 'Total mass [kg/m] =')
        mass(time_iy,1) = str2double(file_strings{file_strings_x+1});
    end 
    if strcmp(file_strings{file_strings_x}, 'FROM BOTTOM [m] =')
        count_height = count_height+1;
        file_strings_x = file_strings_x+1;
        val = str2double(file_strings{file_strings_x});
        val2 = str2double(file_strings{file_strings_x+2});
        hflux(count_height, time_iy) = val2/1000;
        while ~strcmp(file_strings{file_strings_x}, 'FROM BACK [m]') 
            file_strings_x = file_strings_x+1;
        end 
%         count1_back = count1_back+1;
        count2 = 0;
        file_strings_x = file_strings_x+11;
        count2 = count2+1;
        xx(count_height, count2, time_iy) = str2double(file_strings{file_strings_x});

        yy(count_height, count2,time_iy) = val;
        temp(count_height,count2, time_iy) = str2double(file_strings{file_strings_x+1});
        conc(count_height, count2, time_iy) = str2double(file_strings{file_strings_x+1+godNum});
        concIndex(count_height, count2, time_iy) = file_strings_x+1+godNum; 
        while ~strcmp(file_strings{file_strings_x+10}, '-----------------------------')
            count2 = count2+1;
            file_strings_x = file_strings_x+10;
            xx(count_height, count2, time_iy) = str2double(file_strings{file_strings_x});
            xx_index(count_height, count2,time_iy) = file_strings_x;
            yy(count_height, count2, time_iy) = val;
            temp(count_height,count2, time_iy) = str2double(file_strings{file_strings_x+1});
            conc(count_height, count2, time_iy) = str2double(file_strings{file_strings_x+1+godNum});
            concIndex(count_height, count2, time_iy) = file_strings_x+1+godNum;
        end
        count2 = count2+1;
        xx(count_height, count2,time_iy) = 0;
        yy(count_height, count2,time_iy) = yy(count_height, count2-1,time_iy);
        temp(count_height, count2, time_iy) = 0;
        conc(count_height, count2, time_iy)= 0;
    end
    
end
material = material_hold{godNum,1};

% disp(count2/count1_back);
% height = count1_back*.11643;
% disp(bottom(:,:,2));
%     0.1300    0.1100    0.7750    0.8150
% disp(back(:,:,myTime+1));
% set(gca,'Position',[0.1300 0.1100 0.21 0.8150]);
% disp(bflux(:, 1));
% disp(hflux(:,300));

if strcmp(MLR, 'on')
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

if strcmp(Tempat_position, 'on')
    if ~(select_position_x <= 0.012 && select_position_x > 0)
        disp('Sorry, the positions you selected do not exist');
        break;
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
if strcmp(trump2, 'on')
     x = 0;
    while x < 600
        x = x+1;
        mlr(x,1) = ((mass(x,1)-mass(x+1,1))/2)*1000;
    end
    mlr(x+1,1) = mlr(x,1)*1000;
%     disp(size(mlr(:,1)));
%     disp(size(time_hold(:,1)));
%     disp(temp(1,2,550));
     subplot(1,2,1);
    plot(time_hold(:,1), mlr(:,1));
    title('Mass Loss Rate Profile');
        xlim([0 700]);
        %0.001
    ylim([0 1]);
       xlabel('Time [s]'); % x-axis label
        ylabel('Mass Loss Rate [kg/s^2] * 10^-3'); % y-axis label
    if ~(select_position_x <= 0.012 && select_position_x > 0)
        disp('Sorry, the positions you selected do not exist');
        break;
    end 
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
    subplot(1,2,2);
    plot(time_hold(:,1),temperature(:,1));
      xlim([0 600]);
    ylim([250 700]);
    title('Temperature over time at specific location');
      xlabel('Time [s]'); % x-axis label
        ylabel('Temperature [K]'); % y-axis label
end 
if strcmp(trump3, 'on')
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
    contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),conc(:,:,time_hold(idxA,1)),100,'EdgeColor','none');
    shading flat;   
    title('Concentration Profile');
        xlabel('From Back [m]'); % x-axis label
        ylabel('From Bottom [m]'); % y-axis label
        disp(time_hold(idxA,1));
         subplot(1,3,2);
    h = area(yy(:,1,1),hflux(:,time_hold(idxA,1)));
    xlim([0 0.2]);
    ylim([-15 35]);
    title('Heat Flux over time');
    xlabel('Height'); % x-axis label
    ylabel('Heat Flux In kW/m^2'); % y-axis label
    h.FaceColor = 'red';
    view(90,270);
     subplot(1,3,1);
        contourf(xx(:,:,time_hold(idxA,1)),yy(:,:,time_hold(idxA,1)),temp(:,:,time_hold(idxA,1)),100,'EdgeColor','none');
        shading flat;
        set(gca,'Position',[0.1145 0.11 width height]);
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


if strcmp(Heat_flux, 'on')
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
%

%

if strcmp(Temp_profile,'on')
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
 
toc


