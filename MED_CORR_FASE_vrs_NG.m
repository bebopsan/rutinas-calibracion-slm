%%  --------Toma de datos------------
clear all
% close all
clc
%---------------- Preajustar la correcta visualización de la señal que se envia al SLM.
TMfil=1024;
TMcol=1280;
tamH=800;
tamV=600;

pause(0);
figure(2),
    Tgca=[tamH tamV];
    get(gcf);set(gcf,'units','pixels');clc;
    set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 

    get(gca);set(gca,'units','pixels');clc;
    set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
    recuadro=ones(tamV,tamH).*0; recuadro(tamV/2:end,:)=0; %elemento a proyectar
    imshow(recuadro,[0 255]);drawnow;colormap gray;
% uiwait(msgbox('Presione enter si quiere correr la adquisión con esta posición','Correr el programa de adquisición?'));
%-------------------------
%%
clear all
close all
clc
% pause(5)
tic% incia el contador de tiempo

%-----Variables inciales globales
%Configuracion óptica
Pol=+14;
Ana=+122;
Lam4=+60;
%Modulador
BrilloMod=90;
ContrasteMod=180;

camino='Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\';
% TMfil=1024;
% TMcol=1280;

TMcol = 1350;
TMfil = 860;

tamH=800;
tamV=600;
Brillo=255;
Contraste=0;
Exposurenro=-8;

load ([camino,'coor_subima']);
f1=coorsubima(1,1);f2=coorsubima(1,2); f3=coorsubima(1,3); f4=coorsubima(1,4);
c1=coorsubima(1,5); c2=coorsubima(1,6);
filalimite=round(f2-f1)+1;

Nmed=1;
h = fspecial('average',[9 9]);
Corr_fase=zeros(52,Nmed);
NivelGris=zeros(52,1);

%1)--------Activar la captura de video de nuevo

%Inicializacion para que matlab vea la camara
vid=videoinput('winvideo','2','RGB8_1280x1024');% get(vid);% set(vid,'ROIPosition',[0 0 640 512]);
set(vid,'ReturnedColorSpace','grayscale');

%Cambia brillo y contraste
src = getselectedsource(vid); 
get(src);%% muestra otras propiedades.
clc

set(src,'BrightnessMode','manual');
set(src,'Brightness',Brillo);%% Cambia el brillo.

set(src,'ContrastMode','manual');
set(src,'Contrast',Contraste);%% Cambia el contraste.

set(src,'GainMode','manual');
set(src,'Gain',0);%% Cambia el brillo.

set(src,'BacklightCompensationMode','manual');
set(src,'BacklightCompensation','off');%% Cambia el brillo.

set(src,'ExposureMode','manual');
set(src,'Exposure',Exposurenro);%% Cambia el brillo.

get(src)


figure;
        Tgca=[tamH tamV];
        get(gcf);set(gcf,'units','pixels');clc;
        set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 

        get(gca);set(gca,'units','pixels');clc;
        set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
  
vidRes = get(vid, 'VideoResolution');
nBands = get(vid, 'NumberOfBands');

%F = uint8(zeros(vidRes(2),vidRes(1),nBands));

 h = fspecial('average',[9 9]);
for rep=1:Nmed%:10
    
    cont=52
for n=1:5:256
    NG=256-n;
    fprintf('Nivel de gris %g \n',NG)
    recuadro=ones(tamV,tamH).*255; recuadro(tamV/2:end,:)=NG; %elemento a proyectar
    imshow(recuadro,[0 255]);drawnow;colormap gray;
    pause(0.1);
    
    %-------Captura de un frame de video
%     F = uint8(zeros(vidRes(2),vidRes(1),nBands));
%     for n=1%:1:5
%     F=F+getsnapshot(vid)./5;
%     %OJOOOOOOOOO probar: frame=getdata (vid);
%     %flushdata          - Remove buffered image frames from memory.
%     %getdata            - Return acquired image frames from buffer.
%     %---------
%     end
drawnow
     F=getsnapshot(vid);
     %se extrae la imagen de referencia
    imaref=F(f1:f2,c1:c2);
    imaref=imfilter(mat2gray(imaref),h,'replicate');
    imaref=mat2gray(imaref);

    %se extrae la imagen de de corrimiento de fase
    imacorr=F(f3:f4,c1:c2);clear ima
    imacorr=imfilter(mat2gray(imacorr),h,'replicate');
    imacorr=mat2gray(imacorr);
    %imshow(imaref);axis on

 %------------------Imagen de referencia-------------------------

    imaref=mean(imaref,1);
    TFimaref=ifftshift(fft(fftshift(imaref)));clear imaref
    fac=sqrt(1/(size(TFimaref,2)*size(TFimaref,1)));
    TFimaref=TFimaref.*fac;
    radio_mask=2;
    TFimaref(:,floor(size(TFimaref,2)/2)+1-radio_mask:floor(size(TFimaref,2)/2)+1+radio_mask)=0;
    %figure(1);plot(abs(TFimaref));title(['imarecf', num2str(NGI)]);pause(0.5);drawnow;
    [val_max,IX] = sort(abs(TFimaref),'descend');
    %-----------claculo de la fase de referencia
    fase_max1=atan2(imag(TFimaref(1,IX(1))),real(TFimaref(1,IX(1))));
    fase_max2=atan2(imag(TFimaref(1,IX(2))),real(TFimaref(1,IX(2))));
    Fase_prom_0=(fase_max1-fase_max2)/2;%+fase_max2)/2
    clear fase_max1 fase_max2 val_max IX


    %------------------Imagen de corrimiento de fase-------------------------

    imacorr=mean(imacorr,1);
    TFima=ifftshift(fft(fftshift(imacorr)));clear imacorr
    fac=sqrt(1/(size(TFima,2)*size(TFima,1)));
    TFima=TFima.*fac;
    TFima(:,floor(size(TFima,2)/2)+1-radio_mask:floor(size(TFima,2)/2)+1+radio_mask)=0;
    [val_max,IX] = sort(abs(TFima),'descend');

    %-----------claculo de la fase de referencia
    fase_max1=atan2(imag(TFima(1,IX(1))),real(TFima(1,IX(1))));
    fase_max2=atan2(imag(TFima(1,IX(2))),real(TFima(1,IX(2))));
    Fase_prom=(fase_max1-fase_max2)/2;


    %------------------Construccion del vector de fase relativa-------------------------
    NivelGris(cont,1)=NG;
%     vec_fase_rel(2,NG)=Fase_prom_0;
%     vec_fase_rel(3,NG)=Fase_prom;
    Corr_fase(cont,rep)=Fase_prom-Fase_prom_0;
    cont=cont-1;
    clear Fase_prom Fase_prom_0 val_max IX
    %-------------
    
    name=strcat(camino,'PY_',num2str(NG),'.bmp');
    imwrite(F,name);
    clear F
end

% delete(vid)
% Corr_fase=unwrap(Corr_fase);
%Corr_fase=mod(Corr_fase,2*pi)./pi;
Corr_fase(:,rep)=Corr_fase(:,rep)-Corr_fase(end,rep);
Corr_fase0=mod(Corr_fase(:,rep),2*pi)./pi;%versión agl


myunwrap=zeros(size(Corr_fase0));


for k=1:51;
    cambio=Corr_fase0(k+1)-Corr_fase0(k);
    
    if cambio >1
%        myunwrap(k+1:end)=-2;
        Corr_fase0(k+1)=Corr_fase0(k+1)-2;

    end
    if cambio <-1
%        myunwrap(k+1:end)=+2;
        Corr_fase0(k+1)=Corr_fase0(k+1)+2;
%cambiog(k)=cambio;
    end
end
Corr_fase2=Corr_fase0;
%Corr_fase2=Corr_fase0+myunwrap;

% minimo=min(Corr_fase2);
% Corr_fase2=Corr_fase2-Corr_fase2(end);
% Corr_fase=Corr_fase-Corr_fase(1,1);
%vec_u=unwrap(vec_fase_rel(4,NG));
text_T=strcat('Bm= ',num2str(BrilloMod),'  Cm= ',num2str(ContrasteMod),'  P= ',num2str(Pol), '  L4= ',num2str(Lam4),'  A: ',num2str(Ana),'  Ec: ',num2str(Exposurenro));
text_x= 'Nivel de gris(8 bits [0 255])';
text_y='Corrimiento de fase(rad [0 2*pi])';



% for k=1:size(Corr_fase2)-1;
%     cambio=abs(Corr_fase2(k+1)-Corr_fase2(k));
%     if cambio >0.4
%         Corr_fase2(k+1)=Corr_fase2(k);
% 
%     end
% end
Corr_fase(:,rep)=Corr_fase2;
clear cont
clear Corr_fase2
end

delete(vid)

fase_prom=mean(Corr_fase,2);

fase_err=std(Corr_fase,0,2)/sqrt(Nmed);
  


% figure;plot(NivelGris,Corr_fase(:,1),'r-*');

figure;errorbar(NivelGris,fase_prom,fase_err);
%drawnow

xtic=0:15:255;
xlab=0:15:255;
xlab=xlab';
ytic=-0.2:0.1:2;
ylab=-0.2:0.1:2;
ylab=ylab';

grid on;axis on;
title(text_T,'FontWeight','bold','FontSize',10,'FontName','Arial');...
xlabel(text_x,'FontSize',10);ylabel(text_y,'FontSize',10);
get(gca);axis on;box on;
set(gca,'XLimMode','manual');
set(gca,'XLim',[0 255]);
set(gca,'XTick',xtic);
set(gca,'XTick',xlab);
set(gca,'YLimMode','manual');
set(gca,'YLim',[-0.2 2]);
set(gca,'YTick',ytic);
set(gca,'YTick',ylab);  
%figure,plot(NivelGris,Corr_fase,'b-*',NivelGris,myunwrap,'r-*');grid on

resultados=[NivelGris fase_prom fase_err];
 save([camino,'resultados_fase'],'resultados');
dlmwrite('Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\resultados_fase.dat',resultados,'delimiter','\t', 'precision', '%.6f');
fprintf('El proceso demoró %g minutos \n',toc/60)
% close all
return