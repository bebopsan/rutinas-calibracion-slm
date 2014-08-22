%%  --------Toma de datos------------
clear all
% close all
clc
%---------------- Preajustar la correcta visualización de la señal que se envia al SLM.
%TMfil=1920;
%TMcol=1080;
%
% tamH=800;
% tamV=600; 
% 
% pause(0);
% figure(2),
%     Tgca=[tamH tamV];
%     get(gcf);set(gcf,'units','pixels');clc;
%     set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); % set(gcf,'position',[-1280 -512 vidRes(2) vidRes(1)]); 
% 
%     get(gca);set(gca,'units','pixels');clc;
%     set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);
%     recuadro=ones(tamV,tamH).*0; recuadro(tamV/2:end,:)=0; %elemento a proyectar
%     imshow(recuadro,[0 255]);drawnow;colormap gray;
% % uiwait(msgbox('Presione enter si quiere correr la adquisión con esta posición','Correr el programa de adquisición?'));
%-------------------------
%%
% clear all
% close all
% clc
% pause(5)
tic% incia el contador de tiempo

%-----Variables inciales globales
camino='C:\Users\franjas\Documents\rutinas-calibracion-slm\';
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

TMfil=1920;
TMcol=1080;

%%These two lines must be uncommented when using Holoeye LC2002

%tamH=800;
%tamV=600; 

%These two lines must be uncommented when using Holoeye LC2012
tamH=1024;
tamV=768;

load ([camino,'coor_subima']);
f1=coorsubima(1,1);f2=coorsubima(1,2); f3=coorsubima(1,3); f4=coorsubima(1,4);
c1=coorsubima(1,5); c2=coorsubima(1,6);


%1)--------Activar la captura de video de nuevo

%Inicializacion para que matlab vea la camara
vid=videoinput('tisimaq','1');% get(vid);% set(vid,'ROIPosition',[0 0 640 512]);
set(vid,'ReturnedColorSpace','grayscale');

clc

figure;
        Tgca=[tamH tamV];
        
        set(gcf,'units','pixels');clc;
        set(gcf,'position',[TMcol TMfil-tamV Tgca(1,1) Tgca(1,2)]); 
        set(gca,'units','pixels');clc;
        set(gca,'position',[0 0 Tgca(1,1) Tgca(1,2)]);

 h = fspecial('average',[9 9]);
 i=1;
 %%
 for n=1:5:256 % De aquí se cambia cada cuanto se toman imágenes.
     
     NG=256-n;
     fprintf('Nivel de gris %g \n',NG)
     recuadro=ones(tamV,tamH).*255; recuadro(tamV/2:end,:)=NG; %elemento a proyectar
     imshow(recuadro,[0 255]);drawnow;colormap gray;
     pause(0.1);
     drawnow
     F=getsnapshot(vid);
     %se extrae la imagen de referencia
     imaref=F(f1:f2,c1:c2);
     imaref=imfilter(mat2gray(imaref),h,'replicate');
     imaref=mat2gray(imaref);
     
     %Y se condensan en un vector para la minimización
     array_out_ref(:,i)= reshape(imaref,1, size(imaref,2)*size(imaref,1));
     % Y la imágen de corrimiento
     imacorr=F(f3:f4,c1:c2);clear ima
     imacorr=imfilter(mat2gray(imacorr),h,'replicate');
     imacorr=mat2gray(imacorr);
     
     % Lo mismo para la de corrimiento
     array_out_corr(:,i)= reshape(imacorr,1, size(imacorr,2)*size(imacorr,1));
     i=i+1;
     
     clear F
 end
delete(vid)

grayLevels=0:5:255;
initialGuess = 0.1* (0:pi/(52 - 1):pi);
maxIterations=50;
precision=1e-5;
%% Cálculo de los saltos de fase por medio del
% algorítmo de phase shifting

[wrappedPhase_ref, phaseShiftVector_ref, backgroundImage_ref, modulationImage_ref, backgroundVector_ref, modulationVector_ref, phaseShiftVectorHistory_ref] = GetPhaseAdvancedIterativeAlgorithm(array_out_ref, initialGuess, maxIterations, precision);
[wrappedPhase_corr, phaseShiftVector_corr, backgroundImage_corr, modulationImage_corr, backgroundVector_corr, modulationVector_corr, phaseShiftVectorHistory_corr] = GetPhaseAdvancedIterativeAlgorithm(array_out_corr, initialGuess, maxIterations, precision);

% el salto de fase puede resultar de la suma o 
% o de la resta entre las fses de cada sección
% del modulador. A continuación se calcula
% la diferencia y la suma de fases resultantes
% de los saltos de fase en cada región:

shifted_phase = unwrap(phaseShiftVector_corr)/pi; %Renombro los vectores, los desembuelvo y divido por pi.
reference_phase = unwrap(phaseShiftVector_ref)/pi;
phase_difference = shifted_phase - reference_phase;
phase_adition = shifted_phase + reference_phase;

%% Selección de la curva que representa una fase suave

dPhase_diff = 0;
dPhase_sum = 0;
dPhase_corr = 0;

for i = 2:size(grayLevels,2)
    temp_diff = abs(phase_difference(i) - phase_difference(i-1));
    temp_sum = abs(phase_adition(i) - phase_adition(i-1));
    temp_corr = abs(shifted_phase(i) - shifted_phase(i-1));
    if temp_diff > dPhase_diff
        dPhase_diff = temp_diff;
    end
    if temp_sum > dPhase_sum
        dPhase_sum = temp_sum;
    end
    if temp_corr > dPhase_corr
        dPhase_corr = temp_corr;
    end
end


if dPhase_sum < dPhase_diff
    if dPhase_sum < dPhase_corr
        phase_shift = abs(phase_adition); 
    else
        phase_shift = abs(shifted_phase); 
    end
else
    if dPhase_diff < dPhase_corr
       phase_shift = abs(phase_difference);
    else
       phase_shift = abs(shifted_phase);  
    end
end

nombre_archivo = prop.textdata(9);
resultados=[grayLevels', phase_shift', phase_difference', phase_adition', backgroundVector_ref', modulationVector_ref', backgroundVector_corr', modulationVector_corr'];
camino = cell2mat(strcat('C:\Users\franjas\Documents\rutinas-calibracion-slm\'...
            ,nombre_archivo, '_fase'));      
    save(camino, 'resultados');
    %saveas(gcf,camino, 'png')
    
%% Plots the phase shift that better represent our modulation 

text_T=strcat('Bm = ',num2str(Brillo),'  Cm= ',num2str(Contraste),'  P= ',num2str(Pol), '  R1= ',num2str(R1),'  R2= ',num2str(R2),'  A: ',num2str(Ana),'  Ec: ',num2str(Exposurenro));
text_x= 'Nivel de gris(8 bits [0 255])';
text_y='Corrimiento de fase(rad [0 2*pi])';

xtic=0:15:255;
xlab=0:15:255;
xlab=xlab';
ytic=-0.2:0.1:2;
ylab=-0.2:0.1:2;
ylab=ylab';

grid on;axis on;
title(text_T,'FontWeight','bold','FontSize',10,'FontName','Arial');...
xlabel(text_x,'FontSize',10);ylabel(text_y,'FontSize',10);
box on;
set(gca,'XLimMode','manual');
set(gca,'XLim',[0 255]);
set(gca,'XTick',xtic);
set(gca,'XTick',xlab);
set(gca,'YLimMode','manual');
set(gca,'YLim',[-0.2 2]);
set(gca,'YTick',ytic);
set(gca,'YTick',ylab);  
figure; 
plot(grayLevels, shifted_phase ,'r-o');
hold on, plot(grayLevels, reference_phase , 'b-o');
plot(grayLevels, unwrap(mod(phase_shift , 2 * pi)), 'g-o');
hold off
legend({'Modulating' 'Reference' 'Difference'});
saveas(gcf,strcat(camino,'1'), 'png')
    
    
% %% Plots  shifted and reference phases along their difference 
% figure; 
% plot(grayLevels, shifted_phase ,'r-o');
% hold on, plot(grayLevels, reference_phase , 'b-o');
% plot(grayLevels, unwrap(mod(phase_difference , 2 * pi)), 'g-o');
% hold off
% title(text_T,'FontWeight','bold','FontSize',10,'FontName','Arial');
% legend({'Modulating' 'Reference' 'Difference'});
% saveas(gcf,strcat(camino,'1'), 'png')
 
% %% Plots  shifted and reference phases along their adition
% figure; 
% plot(grayLevels, shifted_phase ,'r-o');
% hold on, plot(grayLevels, reference_phase , 'b-o');
% plot(grayLevels, unwrap(mod(phase_adition, 2 * pi)), 'g-o');
% hold off
% title(text_T,'FontWeight','bold','FontSize',10,'FontName','Arial');
% legend({'Modulating' 'Reference' 'Adition'});
% saveas(gcf,strcat(camino,'2'), 'png')

% %% Plots averaged backgrounds vs GL for reference and shifted phases.
% figure; plot(grayLevels,backgroundVector_ref);
% hold on, plot(grayLevels,backgroundVector_corr);
% title('Intensity measure');

dlmwrite(camino, resultados,'delimiter','\t', 'precision', '%.6f');


fprintf('El proceso demoró %g minutos \n',toc/60)

% close all

exit

