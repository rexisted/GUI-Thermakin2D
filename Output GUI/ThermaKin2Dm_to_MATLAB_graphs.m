%Input-------------------------------
FILE_NAME='pmma2Dm.txt';
DISP_TIMESTEP=290;
DISP_HEAT_FLX_MIN=-5;
DISP_HEAT_FLX_MAX=40;
%------------------------------------

file=fopen(FILE_NAME);
file_strings=textscan(file,'%s','delimiter','\t');
fclose(file);

numcomp=sscanf(file_strings{1}{4},'%*s %*s %*s %u');

file_strings_sz=size(file_strings{1});
file_strings_ix=0;
time_ix=0;
temp_conc_ix=0;
while file_strings_ix < file_strings_sz(1,1)
    file_strings_ix=file_strings_ix+1;
    if strcmp(file_strings{1}{file_strings_ix},'Time [s] =')
        file_strings_ix=file_strings_ix+1;
        time_ix=time_ix+1;
        time(time_ix,1)=str2double(file_strings{1}{file_strings_ix});
        file_strings_ix=file_strings_ix+1;
        while ~strcmp(file_strings{1}{file_strings_ix},'Total length [m]  =')
            if strcmp(file_strings{1}{file_strings_ix},'CONCENTRATION [kg/m^3]:')
                temp_conc_ix=temp_conc_ix+1;
                botdst(temp_conc_ix,1)=str2double(file_strings{1}{(file_strings_ix-8)});
                heatfl(temp_conc_ix,1)=str2double(file_strings{1}{(file_strings_ix-6)});
                heatfl(temp_conc_ix,2)=str2double(file_strings{1}{(file_strings_ix-4)});
                mat_block_ix=0;
                file_strings_ix=file_strings_ix+numcomp+1;
                while ~strcmp(file_strings{1}{file_strings_ix},'-----------------------------')
                    mat_block_ix=mat_block_ix+1;
                    for data_ix=1:1:2
                        temp_conc(temp_conc_ix,mat_block_ix,data_ix)=str2double(file_strings{1}{file_strings_ix});
                        file_strings_ix=file_strings_ix+1;
                    end
                    file_strings_ix=file_strings_ix+1;
                    for data_ix=3:1:(2+numcomp)
                        temp_conc(temp_conc_ix,mat_block_ix,data_ix)=str2double(file_strings{1}{file_strings_ix});
                        file_strings_ix=file_strings_ix+1;
                    end
                end
            else
                file_strings_ix=file_strings_ix+1;
            end
        end
        mass(time_ix,1)=str2double(file_strings{1}{(file_strings_ix+3)});
    end
end

num_blks_lns=size(temp_conc);
botdst_ix=1;
time_ix=1;

XXmax=temp_conc(1,1,1)*1000;
YYmax=botdst(1,1)*1000;
Tmin=temp_conc(1,1,2);
Tmax=Tmin;
for temp_conc_ix=1:1:num_blks_lns(1,1)
    if temp_conc_ix>1
        if botdst(temp_conc_ix,1)<botdst((temp_conc_ix-1),1)
            time_ix=time_ix+1;
            botdst_ix=1;
        end
    end
    for mat_block_ix=1:1:num_blks_lns(1,2)
        XX(mat_block_ix,botdst_ix,time_ix)=temp_conc(temp_conc_ix,mat_block_ix,1)*1000;
        if XX(mat_block_ix,botdst_ix,time_ix)>XXmax
            XXmax=XX(mat_block_ix,botdst_ix,time_ix);
        end
        YY(mat_block_ix,botdst_ix,time_ix)=botdst(temp_conc_ix,1)*1000;
        if YY(mat_block_ix,botdst_ix,time_ix)>YYmax
            YYmax=YY(mat_block_ix,botdst_ix,time_ix);
        end
        T(mat_block_ix,botdst_ix,time_ix)=temp_conc(temp_conc_ix,mat_block_ix,2);
        if T(mat_block_ix,botdst_ix,time_ix)>0
            if T(mat_block_ix,botdst_ix,time_ix)<Tmin
                Tmin=T(mat_block_ix,botdst_ix,time_ix);
            end
            if T(mat_block_ix,botdst_ix,time_ix)>Tmax
                Tmax=T(mat_block_ix,botdst_ix,time_ix);
            end
        end
    end
    heatfl_fr(botdst_ix,time_ix)=heatfl(temp_conc_ix,1)/1000;
    botdst_ix=botdst_ix+1;
end

DISP=figure('Position',[800 70 500 600]);
set(DISP,'Color',[1 1 1]);
set(DISP,'DefaultAxesFontName','Times New Roman');
subplot('position',[0.13,0.10,0.23,0.85]);
contourf(XX(:,:,DISP_TIMESTEP),YY(:,:,DISP_TIMESTEP),T(:,:,DISP_TIMESTEP),50,'EdgeColor','none');
axis([0 XXmax 0 YYmax]);
caxis([Tmin Tmax]); colorbar('WestOutside');
xlabel(' \itx \rm(mm) ','FontSize',14);
ylabel('\itT \rm(K)','FontSize',14);
set(gca,'yticklabel',[]);
yl=get(gca,'YLabel'); set(yl,'Position',[-9 50 0]);

subplot('position',[0.46,0.10,0.40,0.85]);
heatfl_fr(botdst_ix,DISP_TIMESTEP)=0;
Y=YY(1,:,DISP_TIMESTEP); Y(botdst_ix)=3*YYmax;
area(heatfl_fr(:,DISP_TIMESTEP),Y,'FaceColor',[1,0.25,0]);
axis([DISP_HEAT_FLX_MIN DISP_HEAT_FLX_MAX 0 YYmax]);
xlabel(' Net Heat Flux (kW/m^2) ','FontSize',14);
ylabel(' \ity \rm(mm) ','FontSize',14);
yl=get(gca,'YLabel'); set(yl,'Position',[-10 50 0]);

time_lbl=title(['time \rm= ', num2str(time(DISP_TIMESTEP,1)),' s']);
set(time_lbl,'Position',[26,92,0],'FontSize',14);