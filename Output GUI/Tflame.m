clc;
clear; 
%----------Read in new data set, thermal wave through the y-direciton------
T=dlmread('x17.5.txt'); % T = [distance from top (m) | Temp (K) | Concentration Ideal (kg/m3) | Concentration Kaowool (kg/m3)
jT=size(T,1); %Total number of data points
M=dlmread('x17.5_MLR_april16.txt');     %This should be formated as a single column of data with no header.  From TK2D, you want: MASS FLOW (kg/s)
M_exp=dlmread('MLR_experimental.txt'); %This should be formated as a single column of data with no header. Units : (g/s-cm)
max_M=max(M_exp);
%The first row of M_exp should correspond to time after burner removal, t = -125 s

%------------ OBJECT BOUNDARIES//INTEGRATION PARAMETERS ----------------
max_y=0.175;    % Total height, y-dimension, of object in TK2D) | UNITS : (m)
Layers = 36;    % Number of Layers reported, y-dimension 
x_insul=0.0059; % Insulation Thickness | UNITS : (m)
Timesteps=601;  % Number of reported time steps (because of how output files work this is often (DURATION + 1)
del_t=1;        % From TK2D.cnd = (TIME STEP)x(TIME STEP OUTPUT FREQUENCY)  | UNITS : (s)
del_y=0.005;    % From TK2D.cnd = (LAYER SIZE)x(LAYERS OUTPUT FREQUENCY)    | UNITS : (m)
w = 5;          % Sample Width | UNITS : (cm)

%------------ EXTERNAL HEAT FLUX 1 ---------------------
%------------Propane Burner/Igniter --------------------
% The igniter is defined, by default, to star at time t = 0s
RAMP1='HOLD';             % Time dependent heat flux mode 'UP' 'DOWN' or 'HOLD'  | Don't forget the apostrophes 
MODE1='CONV';             % Heat transfer mode 'RAD' or 'CONV'  | Don't forget the apostrophes 
t_END1=140;               % time you remove the burner in TK2D (END TIME)  | UNITS : (s)
h_EHF_1 = 20.56;          % CONVECTION COEFF
% POSITION DEPEND1:  | UNITS : same as .cnd file
D011=1970;
Dy11=-50800;
y11=0.01;

% POSITION DEPEND2:  | UNITS : same as .cnd file
D021=1462;
Dy21=0;
y21=0.025;

% POSITION DEPEND3:  | UNITS : same as .cnd file
D031=0;
Dy31=0;
y31=0;

y11=0.01;   % max height of burner exposure
y21=0.025;  % max height of burner exposure

%------------ EXTERNAL HEAT FLUX 2 --------------------
RAMP2='UP';             % Time dependent heat flux mode 'UP' 'DOWN' or 'HOLD'  | Don't forget the apostrophes 
MODE2='RAD';             % Heat transfer mode 'RAD' or 'CONV'  | Don't forget the apostrophes 
t_START2=138;            % time you start the 2nd External Heat flux in TK2D (START TIME) | UNITS : (s)
t_END2=348;              % time you start the 2nd External Heat flux in TK2D (END TIME)   | UNITS : (s)
h_EHF_2 = 20.56;         % CONVECTION COEFF
% POSITION DEPEND1:  | UNITS : same as .cnd file
D012=-3100;
Dy12=0;
y12=0.05;

% POSITION DEPEND2:  | UNITS : same as .cnd file
D022=0;
Dy22=0;
y22=0;

% POSITION DEPEND3:  | UNITS : same as .cnd file
D032=0;
Dy32=0;
y32=0;


%------------ EXTERNAL HEAT FLUX 3 --------------------
RAMP3='HOLD';             % Time dependent heat flux mode 'UP' 'DOWN' or 'HOLD'  | Don't forget the apostrophes 
MODE3='RAD';             % Heat transfer mode 'RAD' or 'CONV'  | Don't forget the apostrophes 
t_START3=348;            % time you start the 2nd External Heat flux in TK2D (START TIME) | UNITS : (s)
t_END3=600;              % time you start the 2nd External Heat flux in TK2D (END TIME)   | UNITS : (s)
h_EHF_3 = 20.56;         % CONVECTION COEFF
% POSITION DEPEND1:  | UNITS : same as .cnd file
D013=-3100;
Dy13=0;
y13=0.05;

% POSITION DEPEND2:  | UNITS : same as .cnd file
D023=0;
Dy23=0;
y23=0;

% POSITION DEPEND3:  | UNITS : same as .cnd file
D033=0;
Dy33=0;
y33=0;




%-------------------- FLAME ----------------------------
%Define our flame expression as a function of TK2D output MLR

% FLAME LENGTH
% Define your flame height expression xf = a*(dm'/dt)^b + c 
% Here, units are:   dm'/dt = [g/s-cm]   ;   xf = [cm]
xf_a= 83.28; 
xf_b= 0.1948;
xf_c= -21.04;

%Critical total mass flux for a non-neative flame height (solve based on
%a, b, and c parameters above       | UNITS : [g/s-cm]
m_crit=8.57E-04;

% CONVECTION COEF (for the flame)
h=18.4;     

% HEAT FLUX INSIDE
Df1= 2220;  % Adiabatic (peak) temperature of flame, T_fl_adiabatic      | UNITS : (K)
yfs= 0.04;  % Height at which you switch from high to low T_fl           | UNITS : (m)
Df2= 1834;  % Flame temperature to defining q"steady farther downstream  | UNITS : (K)

% HEAT FLUX ABOVE
alpha=1.65;     %Define the tail fitting parameter, alpha : (alpha)*(q"steady)*exp(-ln(alpha)*(x*)^2)
x0=3.3;         %Define the fitting parameter for x*=(x+x0)/(xf+x0))     | UNITS : (m)

% BACKGROUND TEMP
T_background=300;     %  | UNITS : (K)

% Heat Flux Gauge Temperature 
% Typically the same as your backgroun temp so that q"net = 0 by default but maybe you're being special.
% The year round average gauge (water) temperature is 18C (here, 291 K)
T_HFg=300;            %  | UNITS : (K)

% Define a matrix with that calculates flame height at every time/dm'/dt output from TK2D
MLR=0*ones(Timesteps,3); % MLR=[ t | dm'/dt (g/s-cm) | xf (cm)]
for i=1:Timesteps
    MLR(i,1)=(i-1)*del_t; %t
    MLR(i,2)=1000/100*M(i); %dm'/dt
    MLR(i,3)=xf_a*MLR(i,2)^xf_b+xf_c; %xf (flame height)
end


%----------------Figure Options-------------------------
% What heat flux to the material do you want to plot? 
% 'HFg' | Heat flux measured by a water cooled gauge @ T_HFg
% 'NET' | Net convective heat flux: accounts for lower q"conv due to high material surface Temp

plot_flux= 'HFg';
% plot_flux = 'NET';

%--------------------END OF Section---------------------










%-----------Determine Sample In-depth Temperature Profile------------------
iter =1;
while T(iter+1,1)~=T(1,1)
    iter=iter+1;
end
Nx=iter; % Number of nodes in primary dimension
del_x=T(1,1)-T(2,1); %Node size


Tmatl=0*ones(Nx,Layers,Timesteps);
xx=0* ones(Nx,Layers,Timesteps);

y=linspace(del_y/2,max_y-del_y/2,Layers);
%y=linspace(0,0.15,Layers);
yy=ones(Nx,Layers);%y is in (m)
for i=1:Nx
    yy(i,:)=y(:);
end
yy; %y is in (m)

c=0;
for i=1:Timesteps
    for L=1:Layers
        for j=1:Nx
            gamma=((i-1)*(Nx*Layers))+((L-1)*Nx)+j;
                if j==1
                xx(j,L,i)=T(gamma-c,1);
                Tmatl(j,L,i)=T(gamma-c,2);

            elseif (T(gamma-c,1)<T(gamma-c-1,1))% && (T(gamma-c,1)>del_x)
                xx(j,L,i)=T(gamma-c,1);
                Tmatl(j,L,i)=T(gamma-c,2);
                 
            elseif gamma ~=1 && T(gamma-c,1)>T(gamma-c-1,1) 
                c=c+1;
                xx(j,L,i)=T(gamma-c,1);
                Tmatl(j,L,i)=T(gamma-c,2);
            
                end
            
        end
    end
end
xx=1000*(xx-x_insul);
max_x=max(max(max(xx)));

% As your sample thins out, you can get VERY high Temperature, this step
% removes them so they look better when plotted on a color scale 
for i=1:Timesteps
    for L=1:Layers
        for j=1:Nx
            if Tmatl(j,L,i) > 5000
                Tmatl(j,L,i) = 800;
            end
        end
    end
end

%Smooth out our Temp/xx profiles in the x direciton
Tmatl_interp=0*ones(Nx*2+1,Layers,Timesteps);
xx_interp=0*ones(Nx*2+1,Layers,Timesteps);
yy_interp=0*ones(Nx*2+1,Layers);

Tmatl_interp(1,:,:)=Tmatl(1,:,:);
Tmatl_interp(Nx*2+1,:,:)=Tmatl(Nx,:,:);

xx_interp(1,:,:)=xx(1,:,:);
xx_interp(Nx*2+1,:,:)=xx(Nx,:,:);

for i=1:Nx*2+1
    yy_interp(i,:)=yy(1,:);
end




for t=1:Timesteps
    for i=2:Nx*2
    if mod(i,2)==0 %if i is even, and thus at a midpoint between nodes I plot//at a Thermakin output cell center
        Tmatl_interp(i,:,t)=Tmatl(i/2,:,t);
        xx_interp(i,:,t)=xx(i/2,:,t);
        
    elseif mod(i,2)== 1
        Tmatl_interp(i,:,t)=(Tmatl((i-1)/2+1,:,t)+Tmatl((i-1)/2,:,t))/2;
        xx_interp(i,:,t)=(xx((i-1)/2+1,:,t)+xx((i-1)/2,:,t))/2;
        
    end
    end
end

%--------------------END OF Section---------------------







%----------------- Smooth/Stretch Temperature & y-dimension data --------------
% Imagine your FEM model, which is cut up into tiny rectangles.
% ThermaKin2D outputs data from the center of these elements; 
% MATLAB likes to plot things defined by the nodes of these elements.
% This section of code takes care of that discrepancy


% Smooth out profiles in  yy direction (extend by del_y/2 at top/bottom)
Tmatl_smooth=0*ones(Nx*2+1,Layers*2+1,Timesteps);
xx_smooth=0*ones(Nx*2+1,Layers*2+1,Timesteps);
yy_smooth=0*ones(Nx*2+1,Layers*2+1);

yy_smooth(:,1)=0;
yy_smooth(:,Layers*2+1)=max_y;

for i = 2:Layers*2
    if mod(i,2)==0 %if i is even, and thus at a midpoint between nodes I plot//at a Thermakin output cell center
        yy_smooth(:,i)=yy_interp(:,i/2);
                
    elseif mod(i,2)== 1
        yy_smooth(:,i)=(yy_interp(:,(i-1)/2+1)+yy_interp(:,(i-1)/2))/2;
        
    end
end


for t=1:Timesteps
    Tmatl_smooth(:,1,t)=Tmatl_interp(:,1,t);
    Tmatl_smooth(:,Layers*2+1,t)=Tmatl_interp(:,Layers,t);

    xx_smooth(:,1,t)=xx_interp(:,1,t);
    xx_smooth(:,Layers*2+1,t)=xx_interp(:,Layers,t);
    
    for i=2:Layers*2
    if mod(i,2)==0 %if i is even, and thus at a midpoint between nodes I plot//at a Thermakin output cell center
        Tmatl_smooth(:,i,t)=Tmatl_interp(:,i/2,t);
        xx_smooth(:,i,t)=xx_interp(:,i/2,t);
        
    elseif mod(i,2)== 1
        Tmatl_smooth(:,i,t)=(Tmatl_interp(:,(i-1)/2+1,t)+Tmatl_interp(:,(i-1)/2,t))/2;
        xx_smooth(:,i,t)=(xx_interp(:,(i-1)/2+1,t)+xx_interp(:,(i-1)/2,t))/2;
        
    end
    end
end

%--------------------END OF Section---------------------













%-------------------------- EXTERNAL HEAT FLUX 1 -------------------------
%--------------------------Propane burner heat flux ----------------------
q_burner_HFg=0*ones(2*Layers+1, Timesteps+1);
q_burner_HFg(:,1)=yy_smooth(1,:)';

q_burner_conv_net=0*ones(2*Layers+1, Timesteps+1);
q_burner_conv_net(:,1)=yy_smooth(1,:)';

if strncmpi(MODE1,'CONV',3) == 1 
    
T_burner_ss=0*ones(2*Layers+1,2);
T_burner_ss(:,1)=yy_smooth(1,:)';
    
    for i=1:2*Layers+1
        
        if T_burner_ss(i,1)<=y11 
            T_burner_ss(i,2)=D011+Dy11*T_burner_ss(i,1);
        
        elseif T_burner_ss(i,1)>y11 && T_burner_ss(i,1)<=y21
            T_burner_ss(i,2)=D021+Dy21*T_burner_ss(i,1);
        
        elseif T_burner_ss(i,1)>y21 && T_burner_ss(i,1)<=y31
            T_burner_ss(i,2)=D031+Dy31*T_burner_ss(i,1);
        
        elseif T_burner_ss(i,1)>y31
            T_burner_ss(i,2)=0;        
        
        end
    end



    for i=2:t_END1+2
        if strncmpi(RAMP1,'UP',3) == 1
                scale1= (i-2)/(t_END1);
            elseif strncmpi(RAMP1,'DOWN',3) == 1
                scale1= (t_END1-(i-2))/(t_END1);
            elseif strncmpi(RAMP1,'HOLD',3) == 1
                scale1=1;
        end
        
        for j=1:2*Layers+1
                       
            if q_burner_conv_net(j,1)<= y11
                q_burner_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-Tmatl_smooth(1,j,i-1)); %propane burner heat flux (kW/m2)
                q_burner_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)
                
            elseif q_burner_conv_net(j,1)> y11 && q_burner_conv_net(j,1)<= y21
                q_burner_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-Tmatl_smooth(1,j,i-1)); %propane burner heat flux (kW/m2)
                q_burner_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)

            elseif q_burner_conv_net(j,1)> y21 && q_burner_conv_net(j,1)<= y31
                q_burner_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-Tmatl_smooth(1,j,i-1)); %propane burner heat flux (kW/m2)
                q_burner_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale1*T_burner_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)
                
            elseif q_burner_conv_net(j,1)>y31 %above the burner shield
                q_burner_conv_net(j,i)=0;
                q_burner_HFg(j,i)=0;
            end
        end
    end
elseif strncmpi(MODE1,'RAD',3) == 1 
        for i=2:t_END1+2
        if strncmpi(RAMP1,'UP',3) == 1
                scale1= (i-2)/(t_END1);
            elseif strncmpi(RAMP1,'DOWN',3) == 1
                scale1= (t_END1-(i-2))/(t_END1);
            elseif strncmpi(RAMP1,'HOLD',3) == 1
                scale1=1;
        end
        for j=1:2*Layers+1
            if strncmpi(RAMP1,'UP',3) == 1
                scale1= (i-2)/(t_END1);
            elseif strncmpi(RAMP1,'DOWN',3) == 1
                scale1= (t_END1-(i-2))/(t_END1);
            elseif strncmpi(RAMP1,'HOLD',3) == 1
                scale1=1;
            end
            
            if q_burner_conv_net(j,1)<= y11
                q_burner_conv_net(j,i)=scale1*(D011+Dy11*q_burner_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)) ; %(kW/m2)
                q_burner_HFg(j,i)=     scale1*(D011+Dy11*q_burner_conv_net(j,1))/1000;
                
            elseif q_burner_conv_net(j,1)> y11 && q_burner_conv_net(j,1)<= y21
                q_burner_conv_net(j,i)=scale1*(D021+Dy21*q_burner_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_burner_HFg(j,i)=scale1*(D021+Dy21*q_burner_conv_net(j,1))/1000;

            elseif q_burner_conv_net(j,1)> y21 && q_burner_conv_net(j,1)<= y31
                q_burner_conv_net(j,i)=scale1*(D031+Dy31*q_burner_conv_net(j,1))/1000+(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_burner_HFg(j,i)=scale1*(D031+Dy31*q_burner_conv_net(j,1))/1000;
                
            elseif q_burner_conv_net(j,1)>y31 %above the burner shield
                q_burner_conv_net(j,i)=0;
                q_burner_HFg(j,i)=0;
            end

        end
    end
end

q_burner_conv_net(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
q_burner_HFg(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
%------------------------End of Propane burner heat flux--------------------
%--------------------------End of EXTERNAL HEAT FLUX 1----------------------


        



%------------------------ External Heat Flux 2 -----------------------------
q_EHF2_HFg=0*ones(2*Layers+1, Timesteps+1);
q_EHF2_HFg(:,1)=yy_smooth(1,:)';

q_EHF2_conv_net=0*ones(2*Layers+1, Timesteps+1);
q_EHF2_conv_net(:,1)=yy_smooth(1,:)';

   
if strncmpi(MODE2,'CONV',3) == 1 
T_EHF2_ss=0*ones(2*Layers+1,2);
T_EHF2_ss(:,1)=yy_smooth(1,:)';
    for i=1:2*Layers+1
        
        if T_EHF2_ss(i,1)<=y12 
            T_EHF2_ss(i,2)=D012+Dy12*T_EHF2_ss(i,1);
        
        elseif T_EHF2_ss(i,1)>y12 && T_EHF2_ss(i,1)<=y22
            T_EHF2_ss(i,2)=D022+Dy22*T_EHF2_ss(i,1);
        
        elseif T_EHF2_ss(i,1)>y22 && T_EHF2_ss(i,1)<=y32
            T_EHF2_ss(i,2)=D032+Dy32*T_EHF2_ss(i,1);
        
        elseif T_EHF2_ss(i,1)>y32
            T_EHF2_ss(i,2)=0;        
        
        end
    end
    for i=t_START2+2:t_END2+2
            if strncmpi(RAMP2,'UP',2) == 1
                scale2= (i-(t_START2+2))/(t_END2-t_START2);
            elseif strncmpi(RAMP2,'DOWN',2) == 1
                scale2= (t_END2-(i-2))/(t_END2-t_START2);
            elseif strncmpi(RAMP2,'HOLD',2) == 1
                scale2=1;
            end
            
        for j=1:2*Layers+1
            if q_EHF2_conv_net(j,1)<= y12
                q_EHF2_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF2_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)
                
            elseif q_EHF2_conv_net(j,1)> y12 && q_EHF2_conv_net(j,1)<= y22
                q_EHF2_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF2_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)

            elseif q_EHF2_conv_net(j,1)> y22 && q_EHF2_conv_net(j,1)<= y32
                q_EHF2_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF2_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale2*T_EHF2_ss(j,2)-T_HFg); %External  heat flux (kW/m2)
                
            elseif q_EHF2_conv_net(j,1)>y32 
                q_EHF2_conv_net(j,i)= (1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1));
                q_EHF2_HFg(j,i)=0;
            end
        end
    end
    
elseif strncmpi(MODE2,'RAD',3) == 1
    for i=t_START2+2:t_END2+2
            if strncmpi(RAMP2,'UP',2) == 1
                scale2= (i-(t_START2+2))/(t_END2-t_START2);
            elseif strncmpi(RAMP2,'DOWN',2) == 1
                scale2= (t_END2-(i-2))/(t_END2-t_START2);
            elseif strncmpi(RAMP2,'HOLD',2) == 1
                scale2=1;
            end
        for j=1:2*Layers+1              
            if q_EHF2_conv_net(j,1)<= y12
                q_EHF2_conv_net(j,i)=scale2*(D012+Dy12*q_EHF2_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF2_HFg(j,i)=scale2*(D012+Dy12*q_EHF2_conv_net(j,1))/1000;
                
            elseif q_EHF2_conv_net(j,1)> y12 && q_EHF2_conv_net(j,1)<= y22
                q_EHF2_conv_net(j,i)=scale2*(D022+Dy22*q_EHF2_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF2_HFg(j,i)=scale2*(D022+Dy22*q_EHF2_conv_net(j,1))/1000;

            elseif q_EHF2_conv_net(j,1)> y22 && q_EHF2_conv_net(j,1)<= y32
                q_EHF2_conv_net(j,i)=scale2*(D032+Dy32*q_EHF2_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF2_HFg(j,i)=scale2*(D032+Dy32*q_EHF2_conv_net(j,1))/1000;
                
            elseif q_EHF2_conv_net(j,1)>y32 
                q_EHF2_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1));
                q_EHF2_HFg(j,i)=0;
            end
        end
    end
end

q_EHF2_conv_net(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
q_EHF2_HFg(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 


%---------------------- End of External heat flux 2 ------------------------





%------------------------ External Heat Flux 3 -----------------------------
q_EHF3_HFg=0*ones(2*Layers+1, Timesteps+1);
q_EHF3_HFg(:,1)=yy_smooth(1,:)';

q_EHF3_conv_net=0*ones(2*Layers+1, Timesteps+1);
q_EHF3_conv_net(:,1)=yy_smooth(1,:)';


    
if strncmpi(MODE3,'CONV',3) == 1 
T_EHF3_ss=0*ones(2*Layers+1,2);
T_EHF3_ss(:,1)=yy_smooth(1,:)';
    for i=1:2*Layers+1
        
        if T_EHF3_ss(i,1)<=y13 
            T_EHF3_ss(i,2)=D013+Dy13*T_EHF3_ss(i,1);
        
        elseif T_EHF3_ss(i,1)>y13 && T_EHF3_ss(i,1)<=y23
            T_EHF3_ss(i,2)=D023+Dy23*T_EHF3_ss(i,1);
        
        elseif T_EHF3_ss(i,1)>y23 && T_EHF3_ss(i,1)<=y33
            T_EHF3_ss(i,2)=D033+Dy33*T_EHF3_ss(i,1);
        
        elseif T_EHF3_ss(i,1)>y33
            T_EHF3_ss(i,2)=0;        
        
        end
    end
    for i=t_START3+2:t_END3+2
            if strncmpi(RAMP3,'UP',2) == 1
                scale3= (i-(t_START3+2))/(t_END3-t_START3);
            elseif strncmpi(RAMP3,'DOWN',2) == 1
                scale3= (t_END3-(i-2))/(t_END3-t_START3);
            elseif strncmpi(RAMP3,'HOLD',2) == 1
                scale3=1;
            end
            
        for j=1:2*Layers+1
            if q_EHF3_conv_net(j,1)<= y13
                q_EHF3_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF3_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)
                
            elseif q_EHF3_conv_net(j,1)> y13 && q_EHF3_conv_net(j,1)<= y23
                q_EHF3_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF3_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-T_HFg); %propane burner heat flux (kW/m2)

            elseif q_EHF3_conv_net(j,1)> y23 && q_EHF3_conv_net(j,1)<= y33
                q_EHF3_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-Tmatl_smooth(1,j,i-1)); %External heat flux (kW/m2)
                q_EHF3_HFg(j,i)=(1/1000)*h_EHF_1*(T_background+scale3*T_EHF3_ss(j,2)-T_HFg); %External  heat flux (kW/m2)
                
            elseif q_EHF3_conv_net(j,1)>y33 
                q_EHF3_conv_net(j,i)= (1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1));
                q_EHF3_HFg(j,i)=0;
            end
        end
    end
    
elseif strncmpi(MODE3,'RAD',3) == 1
    for i=t_START3+2:t_END3+2
                    if strncmpi(RAMP3,'UP',2) == 1
                scale3= (i-(t_START3+2))/(t_END3-t_START3);
            elseif strncmpi(RAMP3,'DOWN',2) == 1
                scale3= (t_END3-(i-2))/(t_END3-t_START3);
            elseif strncmpi(RAMP3,'HOLD',2) == 1
                scale3=1;
            end
        for j=1:2*Layers+1               
            if q_EHF3_conv_net(j,1)<= y13
                q_EHF3_conv_net(j,i)=scale3*(D013+Dy13*q_EHF3_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF3_HFg(j,i)=scale3*(D013+Dy13*q_EHF3_conv_net(j,1))/1000;
                
            elseif q_EHF3_conv_net(j,1)> y13 && q_EHF3_conv_net(j,1)<= y23
                q_EHF3_conv_net(j,i)=scale3*(D023+Dy23*q_EHF3_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF3_HFg(j,i)=scale3*(D023+Dy23*q_EHF3_conv_net(j,1))/1000;

            elseif q_EHF3_conv_net(j,1)> y23 && q_EHF3_conv_net(j,1)<= y33
                q_EHF3_conv_net(j,i)=scale3*(D033+Dy33*q_EHF3_conv_net(j,1))/1000 +(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1)); %(kW/m2)
                q_EHF3_HFg(j,i)=scale3*(D033+Dy33*q_EHF3_conv_net(j,1))/1000;
                
            elseif q_EHF3_conv_net(j,1)>y33 
                q_EHF3_conv_net(j,i)=(1/1000)*h_EHF_1*(T_background-Tmatl_smooth(1,j,i-1));
                q_EHF3_HFg(j,i)=0;
            end
        end
    end
end

q_EHF3_conv_net(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
q_EHF3_HFg(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 


%---------------------- End of External heat flux 3 ------------------------










%---------------Define Flame Temperature profile------------------------
%Define our flame expression as a function of TK output MLR
%let's define flame temps above and below the transition height
Tsteady=0*ones(2*Layers+1,2); 
Tsteady(:,1)=yy_smooth(1,:)';
for i=1:2*Layers+1
    if Tsteady(i,1)<=yfs % height at which q"steady changes 
        Tsteady(i,2)=Df1;
    elseif Tsteady(i,1)>yfs
        Tsteady(i,2)=Df2;
    end
end

T_flame=0*ones(2*Layers+1, Timesteps+1);
T_flame(:,1)=yy_smooth(1,:)';

for i=2:Timesteps+1
    for j=1:2*Layers+1
        if MLR(i-1,2) < m_crit
            T_flame(j,i)=0;
        elseif MLR(i-1,2) >= m_crit
            if T_flame(j,1)<=(1/100)*MLR(i-1,3)
                T_flame(j,i)=Tsteady(j,2);
        
            elseif T_flame(j,1)>(1/100)*MLR(i-1,3)
                T_flame(j,i)=Tsteady(j,2)*alpha*(exp(log(1/alpha)*((T_flame(j,1)+x0/100)/((MLR(i-1,3)/100)+x0/100))^2));
                
            end
        end
    end
end


%Define heat flux to sample (measured by HFg and net, convective - adjusted for matl surface temp)
q_fl_conv_net=0*ones(2*Layers+1, Timesteps+1);
q_fl_conv_net(:,1)=yy_smooth(1,:)';

q_fl_HFg=0*ones(2*Layers+1, Timesteps+1);
q_fl_HFg(:,1)=yy_smooth(1,:)';


for i=2:Timesteps+1
    for j=1:2*Layers+1
        if MLR(i-1,2) < m_crit      % Is there a flame yet? If not:
            q_fl_conv_net(j,i)=0;
            q_fl_HFg(j,i)=0;
        elseif MLR(i-1,2) >= m_crit % Is there a flame yet? If yes:
               q_fl_conv_net(j,i)=(1/1000)*h*(T_background+T_flame(j,i)-Tmatl_smooth(1,j,i-1));
               q_fl_HFg(j,i)=(1/1000)*h*(T_background+T_flame(j,i)-T_HFg);
            
        end
    end
end
q_fl_conv_net(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
q_fl_HFg(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 

% if strncmpi(MODE1,'CONV',3) == 1 && strncmpi(MODE2,'RAD',3) == 1
%     q_fl_conv_net(:,2:Timesteps+1) = q_fl_conv_net(:,2:Timesteps+1) + q_EHF2_HFg(:,2:Timesteps+1);
%     q_fl_HFg(:,2:Timesteps+1) = q_fl_HFg(:,2:Timesteps+1) + q_EHF2_HFg(:,2:Timesteps+1);    
% end
% 
% if strncmpi(MODE1,'RAD',3) == 1 && strncmpi(MODE2,'CONV',3) == 1
%     q_fl_conv_net(:,2:Timesteps+1) = q_fl_conv_net(:,2:Timesteps+1) + q_burner_HFg(:,2:Timesteps+1);
%     q_fl_HFg(:,2:Timesteps+1) = q_fl_HFg(:,2:Timesteps+1) + q_burner_HFg(:,2:Timesteps+1);    
% end
% 
% 
% if strncmpi(MODE1,'RAD',3) == 1 && strncmpi(MODE2,'RAD',3) == 1
%     q_fl_conv_net(:,2:Timesteps+1) = q_fl_conv_net(:,2:Timesteps+1) + q_burner_HFg(:,2:Timesteps+1) + q_EHF2_HFg(:,2:Timesteps+1);
%     q_fl_HFg(:,2:Timesteps+1) = q_fl_HFg(:,2:Timesteps+1) + q_burner_HFg(:,2:Timesteps+1) + q_EHF2_HFg(:,2:Timesteps+1);
% end



%Define Total flux to sample (measured by HFg and net, convective - adjusted for matl surface temp)
q_total_conv_net=0*ones(2*Layers+1, Timesteps+1);
q_total_conv_net(:,1)=yy_smooth(1,:)';

q_total_HFg=0*ones(2*Layers+1, Timesteps+1);
q_total_HFg(:,1)=yy_smooth(1,:)';

q_total_conv_net(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 
q_total_HFg(2*Layers+1+1,1)=1; % a trick to make shading extend to the left 

for i = 2 : Timesteps+1
q_total_conv_net(:,i)=q_fl_conv_net(:,i) + q_burner_conv_net(:,i) + q_EHF2_conv_net(:,i) + q_EHF3_conv_net(:,i);
q_total_HFg(:,i)=q_fl_HFg(:,i) + q_burner_HFg(:,i) + q_EHF2_HFg(:,i) + q_EHF3_HFg(:,i);
end
%--------------------END OF Section---------------------





% ----------------- Pretty Pictures ------------------------
% ----------------- Pretty Pictures ------------------------

%Side by side : In depth Temperature Profile, q" to sample, and dm'/dt

fig1=figure;
set(fig1, 'Position', [400 50 1400 900])

    for i = 2:Timesteps+1
        time = MLR(i-1,1);
        set(0,'DefaultAxesFontName','Times New Roman');
        set(gca,'FontSize',16)
        %%Temperature profile
        subplot('position',[0.05,0.1,0.1,0.8]);
        axis([0,1000*x_insul,0,max_y])
        %contourf(xx(:,:,i),yy,Tmatl(:,:,i),50,'EdgeColor','none')
    %     surf(xx(:,:,i-1),yy,Tmatl(:,:,i-1),Tmatl(:,:,i-1),'EdgeColor','none')
    %     %original
        surf(xx_smooth(:,:,i-1),yy_smooth,Tmatl_smooth(:,:,i-1),Tmatl_smooth(:,:,i-1),'EdgeColor','none')%interpolated/smoothed in both x and y
        caxis([300 700])
        colorbar('WestOutside')
        lcolorbar('cake')
        format long g
        axis([0,1000*x_insul,0,max_y])
%         xt = [0,2,4,6];
        set(gca,'XTick',[0,2000*del_x,4000*del_x,6000*del_x])
%         set(gca,'XTickLabel', sprintf('%.0f|',xt))
        set(gca,'YTickLabel','')
        ylabel('\itT \rm(K)','FontSize',16)
        xlabel(' \itx \rm(mm) ','FontSize',16) 
    %     temp=title('\itT \rm(K)');
    %     set(temp,'Position',[0.0035,0.08,0]);
        set(gcf,'PaperPositionMode','auto')
        set(gca,'FontSize',16)


        %%Heat flux profile
        subplot('position',[0.225,0.1,0.25,0.8])
        set(gca,'FontSize',16)
        %Total heat flux to material (Red)
    %     if strncmpi(plot_flux,'NET',3) == 1 
    %         area(q_total_conv_net(:,i),q_fl_conv_net(:,1),'FaceColor',[1,0,0]);
    %     elseif strncmpi(plot_flux,'HFg',3) == 1 
    %         area(q_total_HFg(:,i),q_fl_HFg(:,1),'FaceColor',[1,0,0]);
    %     end
        hold on
        %Flame heat flux to material (Orange Red)
        if strncmpi(plot_flux,'NET',3) == 1 
            area(q_fl_conv_net(:,i),q_fl_conv_net(:,1),'FaceColor',[1,0.25,0]);
        elseif strncmpi(plot_flux,'HFg',3) == 1 
            area(q_fl_HFg(:,i),q_fl_HFg(:,1),'FaceColor',[1,0.25,0]);
        end

        %Add in a layer for the burner/igniter Heat flux (Orange)
        if time <= t_END1
        if strncmpi(plot_flux,'NET',3) == 1 
            area(q_burner_conv_net(:,i),q_burner_conv_net(:,1),'FaceColor',[1,0.5,0]);
        elseif strncmpi(plot_flux,'HFg',3) == 1 
            area(q_burner_HFg(:,i),q_burner_HFg(:,1),'FaceColor',[1,0.5,0]);
        end
        end
        
        %Add in a layer for External Heat Flux 2 (Yellow)
        if time >= t_START2 && time <= t_END2
        if strncmpi(plot_flux,'NET',3) == 1
            area(q_EHF2_conv_net(:,i),q_EHF2_conv_net(:,1),'FaceColor',[1,1,0]);
        elseif strncmpi(plot_flux,'HFg',3) == 1 
            area(q_EHF2_HFg(:,i),q_EHF2_HFg(:,1),'FaceColor',[1,1,0]);
        end
        end
        
        %Add in a layer for External Heat Flux 3 (Magenta)
        if time >= t_START3 && time <= t_END3
        if strncmpi(plot_flux,'NET',3) == 1
            area(q_EHF3_conv_net(:,i),q_EHF3_conv_net(:,1),'FaceColor',[1,0,1]);
        elseif strncmpi(plot_flux,'HFg',3) == 1 
            area(q_EHF3_HFg(:,i),q_EHF3_HFg(:,1),'FaceColor',[1,0,1]);
        end
        end
        hold off


        format long g
        axis([0,60,0,max_y])
        if strncmpi(plot_flux,'NET',3) == 1 
            xlabel('\itq^"_c_o_n_v_,_n_e_t \rm(kW m^-^2)')
        elseif strncmpi(plot_flux,'HFg',3) == 1 
            xlabel('\itq^"_H_F_g \rm(kW m^-^2)')
        end

        ylabel('\ity \rm(m)')
        yt = [0,0.05,0.10,0.015];
        set(gca,'YTick',[0,0.05,0.10,0.15])
    %     set(get(gca,'YLabel'),'Rotation',0.0)
        time=title(['\itt \rm= ', num2str(i-2),' s']);
        set(time,'Position',[70,max_y+0.01,0]);


        %Mass Loss Rate
        subplot('position',[0.55,0.3,0.4,0.4]) 
        hold on
        scatter(MLR(1:i-1,1),MLR(1:i-1,2),'x','r')
        scatter(MLR(1:i-1,1),M_exp(1:i-1),'o','k')
        axis([0,Timesteps,0,1.1*max_M])
        ylabel('dm''/dt (g s^-^1 cm^-^1)','FontSize',16)
        xlabel('Time After Burner Exposure (s)','FontSize',16) 
        set(gca,'XTick',[0,60,120,180,240,300,360,420,480,540,600,660,720])
        legend('ThermaKin2D','Experimental','Location','NorthWest')
        set(gca,'FontSize',16)
    %     set(gcf,'PaperPositionMode','auto')


        eval(['print -dpng flame' num2str(i-2) '.png']);
        pause(0.01)
        hold off
    clf
    end





%%%--- Just the q"net heat flux profile/area plot ------------
% figure
% for i =2:Timesteps+1
%     area(q_fl_burner(:,i),q_fl_burner(:,1),'FaceColor',[1,0,0]);
%     hold on
%     area(q_burner(:,i),q_burner(:,1),'FaceColor',[1,0.5,0]);
%     axis([0,60,0,0.15])
%     title(['t = ', num2str(i-1),'s'])
%     xlabel('Heat Flux, q" (kW/m^2)')
%     ylabel('y (m)')
%     pause(0.1)
%     hold off
% end



%%%------- Just the in depth Temperature profile plots -----------
% fig1=figure;
% 
% set(fig1, 'Position', [400 100 300 750])
% 
% for i = 2:Timesteps+1
%     axis([0.006,0.05,0,0.15])
%     %contourf(xx(:,:,i),yy,Tmatl(:,:,i),50,'EdgeColor','none')
%     surf(xx(:,:,i),yy,Tmatl(:,:,i),Tmatl(:,:,i),'EdgeColor','none')
%     caxis([300 700])
%     colorbar('WestOutside')
%     title(num2str(i-1))
%     axis([0.000525,0.005,0,0.15])
%     xlabel('x (m)') 
%     ylabel('y (m)') 
%     set(gcf,'PaperPositionMode','auto')
%    % eval(['print -dpng iflame_norad3_' num2str(i-1) '.png']);
%     pause(0.00333)
% end


%-------------- q"flow (conduction through material top surface)------
% k_ideal=0.24;
% for i=1:Timesteps
%     for L=1:2*Layers+1
%         q(L,i)=(1/1000)*k_ideal*((Tmatl(1,L,i)-Tmatl(2,L,i))/(xx(1,L,i)-xx(2,L,i)));
%     end
% end


% % ----ESTIMATED HEAT FLUX AT SURFACE--------
% figure
% for i=1:Timesteps
%     plot(q(:,i),yy(1,:));
%     title(num2str(i-1))
%     axis([0,75,0,0.15])
%     xlabel('Heat Flux, q" (kW/m^2)')
%     ylabel('y (m)')
%    eval(['print -dpng qflame_norad_3_' num2str(i-1) '.png']);
%     pause(0.1)
% end
% 
% 
% 
