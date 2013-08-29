
%-------------------------
%%
%---------------- Preajustar la correcta visualización de la señal que se envia al SLM.
% TMfil=1024;
% TMcol=1280;

TMcol = 1350;
TMfil = 860;

tamH=800;
tamV=700;

figure,
    Tgca=[tamH tamV];
    get(gcf);set(gcf,'units','pixels');clc;
    set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 

    get(gca);set(gca,'units','pixels');clc;
    set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
    recuadro=ones(tamV,tamH).*255; recuadro(tamV/2:end,:)=0; %elemento a proyectar
    imshow(recuadro,[0 255]);drawnow;colormap gray;
%     uiwait(msgbox('Presione enter si quiere correr la adquisión con esta posición','Correr el programa de adquisición?'));
    close all;
    %-------------------------
    %%
    clear all
    clc

    tic% incia el contador de tiempo

    %-----Variables inciales globales
    camino='Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\';
%     TMfil=1024;
%     TMcol=1280;

TMcol = 1450;
TMfil = 970;
    tamH=800;
    tamV=700;
    
    vec_Int=zeros(52,1);
    NivelGris=zeros(52,1);
%Arqui Óptica
Pol=+14;
Ana=+122;
Lam4=60;
%Modulador
BrilloMod=90;
ContrasteMod=180;
%Cámara
Brillo=255;
Contraste=0;
Exposurenro=-8;
    
    load ([camino,'coor_subima']);
    f1=coorsubima(1,1);f2=coorsubima(1,2); f3=coorsubima(1,3); f4=coorsubima(1,4);
    c1=coorsubima(1,5); c2=coorsubima(1,6);
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

    % F = uint8(zeros(vidRes(2),vidRes(1),nBands));
    cont=52;

    for n=1:5:256
        NG=256-n;
        fprintf('Nivel de gris %g \n',NG)
        recuadro=ones(tamV,tamH); recuadro(:,:)=NG; %elemento a proyectar
        imshow(recuadro,[0 255]);drawnow;colormap gray;
        pause(0.1);

        %-------Captura de un frame de video
        F=getsnapshot(vid);

        %---------

        %se extrae la imagen de referencia
        ima=F(f1:f4,c1:c2);
        Int_prom=mean(ima(:));
        Amp_prom=sqrt(Int_prom);

        %------------------Construccion del vector de intensidad relativa-------------------------
        NivelGris(cont,1)=NG;
        vec_Int(cont,1)=Int_prom;
        clear ima Int_prom
        cont=cont-1;
        name=strcat(camino,'IY_',num2str(NG),'.bmp');
        imwrite(F,name);
        clear F
    end



    vec_Int(:)= vec_Int(:)./max(vec_Int(:));
text_T=strcat('Bm= ',num2str(BrilloMod),'  Cm= ',num2str(ContrasteMod),'  P= ',num2str(Pol), '  L4 ind= ',num2str(Lam4),'  A ind: ',num2str(Ana),'  Ec: ',num2str(Exposurenro));
text_x= 'Nivel de gris(8 bits [0 255])';
text_y='Amplitud Normalizada';
    
    figure;plot(NivelGris,vec_Int,'r-*');
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
set(gca,'YLim',[0 1]);
set(gca,'YTick',ytic);
set(gca,'YTick',ylab);  
    
    resultados=[ NivelGris vec_Int];
     save([camino,'resultados_Int'],'resultados');
    dlmwrite('Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\resultados_Int.dat',resultados,'delimiter','\t', 'precision', '%.6f');
    fprintf('El proceso demoró %g minutos \n',toc/60)
    % close all

    return
    %------------------Imagen de referencia-------------------------
