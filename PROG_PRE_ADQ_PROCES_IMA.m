%I)---------PRIMER PROGRAMA: Toma una imagen y la usa para el prepocesamiento antes de la toma de datos.


%% 1)--------Visualizar el video a escala [800 600]

clear all
% close all
clc
TMfil=1024;
TMcol=1280;

%Inicializar la camara
vid=videoinput('winvideo','2','RGB8_1280x1024');% get(vid);% set(vid,'ROIPosition',[0 0 640 512]);
set(vid,'ReturnedColorSpace','grayscale');

val_Brightness =255;
val_Contrast = 0;
val_Gain = 0;
val_BacklightCompensation ='off';
val_Exposure = -11;
seguir=1;

src = getselectedsource(vid);
% con  imaqhelp(src,'nombredelapropiedad') y/o propinfo(src,'nombredelapropiedad')  se pueden obtener los valores
% posibles para determinada propiedad 
set(src,'BrightnessMode','manual');
set(src,'Brightness',val_Brightness);%

set(src,'ContrastMode','manual');
set(src,'Contrast',val_Contrast);%

set(src,'GainMode','manual');
set(src,'Gain',val_Gain);%

set(src,'BacklightCompensationMode','manual');
set(src,'BacklightCompensation',val_BacklightCompensation);%

set(src,'ExposureMode','manual');
set(src,'Exposure',val_Exposure);%

val_Gamma=100;
set(src,'Gamma',val_Gamma);%


%Ajustar el video a una ventana de 800 x 600 pixeles 
vidRes = get(vid, 'VideoResolution');
nBands = get(vid, 'NumberOfBands');
figure(1);hImage = image( zeros(vidRes(2),vidRes(1),nBands));
Tgca=[800 600];
get(gcf);set(gcf,'units','pixels');clc;
set(gcf,'position',[50 (TMfil-Tgca(1,2))/2 Tgca(1,1)+100 Tgca(1,2)+100]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 
get(gca);set(gca,'units','pixels');clc;
set(gca,'position',[50 50 Tgca(1,1) Tgca(1,2)]);

%Visualizar el video = 
preview(vid,hImage);

% 2)---Cambiar las propiedades de la cámara: cambie los valores y vuelva a correr esta cell del programa

src = getselectedsource(vid); 
get(src);%% muestra otras propiedades.
clc
% %propinfo(src,'Exposure')

%
TMcol = 1350;
TMfil = 860;

tamH = 800;
tamV = 600;

figure(5);
        Tgca=[tamH tamV];
        get(gcf);set(gcf,'units','pixels');clc;
        set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 

        get(gca);set(gca,'units','pixels');clc;
        set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
        
        NG=0;
    fprintf('Nivel de gris %g \n',NG)
    recuadro=ones(tamV,tamH).*255; recuadro(tamV/2:end,:)=NG; %elemento a proyectar
    imshow(recuadro,[0 255]);drawnow;colormap gray;

%%


%CamProperties=cameraproperties(vid,val_Brillo,val_Contraste,val_Gain,val_BacklightCompensation,val_Exposure)

%  h=msgbox('X^2 + Y^2','Title','custom',Data,hot(64),CreateStruct);
F=uint8(zeros(vidRes(2),vidRes(1)));
seguir=1;
figure(2);
Tgca=[300 225];TMfil=1024;TMcol=1280;
get(gcf);set(gcf,'units','pixels');clc;
set(gcf,'position',[(TMcol-Tgca(1,1)-80) (TMfil-Tgca(1,2))/2 Tgca(1,1)+80 Tgca(1,2)+100]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 
get(gca);set(gca,'units','pixels');clc;
set(gca,'position',[40 40 Tgca(1,1) Tgca(1,2)]);
while seguir==1
    
    % Le puse la llamada a la función dentro del while
    [seguir CamProperties]=cameraproperties(vid,val_Brightness,val_Contrast,val_Gain,val_BacklightCompensation,val_Exposure);
    F=getsnapshot(vid);drawnow
    %figure(2)=hist_mean_std_Visib_frame_adq(F);
    X=0:255;
    [N,Yhist]= hist(F(:),X);
    
    imhist(mat2gray(F))
    
    %     Visualizar el histograma;
%     text_T=strcat('Valor Medio= ',num2str(mean(F(:))),'   Error',num2str(std(F(:))));%'Histograma de la imagen de un frame del video'
%     text_x= 'Nivel de gris(8 bits [0 255])';
%     text_y='frecuencia del nivel de gris';
%     bar(Yhist,N);axis on;xlim([0 255]);grid on;...
%         title(text_T,'FontWeight','bold','FontSize',14,'FontName','Arial');...
%         xlabel(text_x,'FontSize',12);ylabel(text_y,'FontSize',12);%drawnow
%     
%     clear Yhist N
    
end

uiwait(msgbox('¿Desea guardar la imagen con el nombre especificado en name?','Guardar?'))

camino='Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\';
name=strcat(camino,'prueba.bmp');
imwrite(F,name);
clear F
close all
brillo=get(src,'Brightness')
contraste=get(src,'Contrast')

%%

%II)---------SEGUNDO PROGRAMA: Pre_porcesamiento.

clear all
close all
clc

tipo= 'Seleccionar_subimagenes';
%tipo= 'Usar_coor_ant_subimagenes';
seguir=1;
TMfil=1024;
TMcol=1280;
while (seguir==1)

    switch tipo

        case 'Seleccionar_subimagenes'
            camino='Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\';
            name=strcat(camino,'prueba.bmp');
            imagen=imread(name);
            
            
            figure,Tgca=[size(imagen,2) size(imagen,1)];
            get(gcf);set(gcf,'units','pixels');clc;
            set(gcf,'position',[0 0 Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]);

            get(gca);set(gca,'units','pixels');clc;
            set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
            uiwait(msgbox('Seleccione la subimagen NO útil de la sgt imagen'));
            [sub_ima,cor_rec] = imcrop(imagen);

            c1=round(cor_rec(1));
            f2=round(cor_rec(2));

            c2=round(c1+cor_rec(3));
            f3=round(f2+cor_rec(4));

            close all
            IR=imagen(1:f2,c1:c2);
            IC=imagen(f3:end,c1:c2);
            f2=size(IR,1);
            imagen=[IR;IC];clear IR IC sub_ima cor_rec
            close all
            
            figure,Tgca=[size(imagen,2) size(imagen,1)];
            get(gcf);set(gcf,'units','pixels');clc;
            set(gcf,'position',[100 0 Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]);

            get(gca);set(gca,'units','pixels');clc;
            set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
            [sub_ima,cor_rec] = imcrop(imagen);
            imagesc(imagen);colormap gray;
            
            uiwait(msgbox('SELECCIONE UN PUNTO QUE INDIQUE LA POSICION DE LA PRIMERA FILA'));
            
            posN=round(ginput(1));
            f1=posN(1,2);
            delfila=round(f2-f1);
            f4=f3+delfila+1;
            Row_sub=[f1 f2 f3 f4];
            Column_sub=[c1 c2];
            coorsubima=[Row_sub Column_sub];
            close all
            delta=round(f2-f1);
            IR=imagen(f1:f2,:);tamRER=size(IR)
            IC=imagen(f2:f2+delta,:);tamCORR=size(IC)
            imagen=[IR;IC];clear IR IC posN

            %             figure(3);get(gcf);set(gcf,'units','pixels');
            %             clc
            %             set(gcf,'position',[0 0 1280 1024]);
            f =figure,Tgca=[size(imagen,2) size(imagen,1)];
            get(gcf);set(gcf,'units','pixels');clc;
            set(gcf,'position',[100 0 Tgca(1,1)+100 Tgca(1,2)+200]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]);

            get(gca);set(gca,'units','pixels');clc;
            set(gca,'position',[50 150 Tgca(1,1) Tgca(1,2)]);
            [sub_ima,cor_rec] = imcrop(imagen);
       
            imagesc(imagen);colormap gray;title('Imagen final para calcular el corrimieto de fase');
            hpop = uicontrol('Parent', f,'Style', 'popup', 'String', 'Reiniciar|Finalizar',...
                'Position', [(Tgca(1,1)+24)/2 25 100 70], 'Callback', 'uiresume(gcbf)');
            %'Position', [200 5 100 70], 'Callback', 'Que_hacer');
            uiwait(gcf);
            val=get(hpop,'Value');

            if val==1
                close(f)
                disp('Se reiniciará el proceso de selección de las subimagenes')
                seguir=1;
                continue
            elseif val==2
                disp('Se terminará el proceso de selección, se guardan las coordenadas actuales y continua la ejecución')
                close(f);
                camino='Z:\Documents\AREA53\GRUPO DE OPTICA\MAO\07 - CAMERA\';
                save([camino,'coor_subima'],'coorsubima');
%                 save([camino,'coor_subima'],'coor_subima']);
                seguir=0;
            end



        case 'Usar_coor_ant_subimagenes'
            load coor_subima

    end
end

return

%%%% falta incluir la parte de el radio del orden cero