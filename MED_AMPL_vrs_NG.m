
%-------------------------
%%
%---------------- Preajustar la correcta visualización de la señal que se envia al SLM.
TMcol = 1300;
TMfil = 768;

tamH=800;
tamV=700;

figure,
    Tgca=[tamH tamV];
    %get(gcf);
    set(gcf,'units','pixels');clc;
    set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 
    %get(gca);
    set(gca,'units','pixels');clc;
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
    camino='C:\Users\franjas\Documents\rutinas-calibracion-slm\';

TMcol = 1920;
TMfil = 1080;

% tamH=1024;
% tamV=768;

tamH=800;
tamV=600;

vec_Int=zeros(52,1);
NivelGris=zeros(52,1);
% Carga de propiedades de la medida
prop = importdata('parametros_medida.txt'); % Nombre del archivo que exporta labview
    %Arqui Óptica
    Pol = prop.data(1);
    Ana = prop.data(4);
    R1 = prop.data(2);
    R2 = prop.data(3);
    
    %Cámara
    Brillo = prop.data(6);
    Contraste= prop.data(8);
    Exposurenro=prop.data(5);
    
    load ([camino,'coor_subima']);
    f1=coorsubima(1,1);f2=coorsubima(1,2); f3=coorsubima(1,3); f4=coorsubima(1,4);
    c1=coorsubima(1,5); c2=coorsubima(1,6);
    %1)--------Activar la captura de video de nuevo

    %Inicializacion para que matlab vea la camara
    vid=videoinput('tisimaq','1');% get(vid);% set(vid,'ROIPosition',[0 0 640 512]);
    
    %Cambia brillo y contraste
    src = getselectedsource(vid);
    %get(src);%% muestra otras propiedades.
    clc
 
    figure;
    Tgca=[tamH tamV];
    %get(gcf);
    set(gcf,'units','pixels');clc;
    set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]);

    %get(gca);
    set(gca,'units','pixels');clc;
    set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);

    vidRes = get(vid, 'VideoResolution');
    nBands = get(vid, 'NumberOfBands');

    % F = uint8(zeros(vidRes(2),vidRes(1),nBands));
    cont=52;

    for n=1:5:256 % De aquí se cambia cuantos pasos deben correrse.
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
%         name=strcat(camino,'IY_',num2str(NG),'.bmp');
%         imwrite(F,name);
        clear F
    end
    
    vec_Int(:)= vec_Int(:)./max(vec_Int(:));
text_T=strcat('Bm = ',num2str(Brillo),'  Cm= ',num2str(Contraste),'  P= ',num2str(Pol), '  R1= ',num2str(R1),'  R2= ',num2str(R2),'  A: ',num2str(Ana),'  Ec: ',num2str(Exposurenro));
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
%get(gca);
axis on;box on;
set(gca,'XLimMode','manual');
set(gca,'XLim',[0 255]);
set(gca,'XTick',xtic);
set(gca,'XTick',xlab);
set(gca,'YLimMode','manual');
set(gca,'YLim',[0 1]);
set(gca,'YTick',ytic);
set(gca,'YTick',ylab);  
    nombre_archivo = prop.textdata(9);
    resultados=[ NivelGris vec_Int];
    camino = cell2mat(strcat('C:\Users\franjas\Documents\rutinas-calibracion-slm\'...
            ,nombre_archivo,'_amp'));      
    save(camino, 'resultados');
    saveas(gcf,camino, 'png')
    dlmwrite(camino, resultados,'delimiter','\t', 'precision', '%.6f');
    fprintf('El proceso demoró %g minutos \n',toc/60)
    % close all
exit
    return
    %------------------Imagen de referencia-------------------------
