clc
clear

t= 0*ones(5,1); % Array holding each of your layer thicknesses and the material component index
%how thick is each layer (from top to bottom)
t(1,1) = 0.01;
t(2,1) = 0.02;
t(3,1) = 0.015;
t(4,1) = 0.01;
t(5,1) = 0.005;

%What material is each layer made of? (you'll have to map these numbers to
%the components that are available in the current model (you've done such
%mapping before)
t(1,2) = 1;
t(2,2) = 2;
t(3,2) = 3;
t(4,2) = 1;
t(5,2) = 4;

Nt=size(t,1); % # of layers
t_tot=sum(t(:,1));% total thickness
 
 colors={'y','m','c','r','g','b','k'};
 figure
 for i = 1:Nt
     area([0 5*t_tot],[sum(t(i:Nt,1)) sum(t(i:Nt,1))],'FaceColor',colors{t(i,2)}); 
     hold on
 end
 
 axis([0,5*t_tot,0,t_tot])
 ylabel('\itx \rm(m)')
 set(gca,'XTick',[])
 % color box legend on left
   legend('PMMA', 'Kydex', 'PVC', 'PMMA','Kaowool', 'Location', 'EastOutside');
   
 %OR  we can just add labels directly where we need them:
 
 for i = 1:Nt
     text((5/2)*t_tot, sum(t(i:Nt,1))-t(i)/2, num2str(t(i,2)), 'HorizontalAlignment', 'right');
 end
 
 % for multiple components in the same layer, we may want to use the
 % command 'hatchfill' :
 %http://blogs.mathworks.com/pick/2011/07/15/creating-hatched-patches/