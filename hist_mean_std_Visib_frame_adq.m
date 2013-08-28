
function figurehist=hist_mean_std_Visib_frame_adq(F)


%Tercer paso: Almacenar el histograma,los niveles de gris, calcular el valor promedio...
%,la desviación estandar, la visibilidad de las franjas y graficar ;
%----------------------------------------------------
%Almacenar el histograma,los niveles de gris
% F=imread('D:\2013\Matlab\Program_histo_visibilidadfrajas\IntCos_1.bmp');
NGris=256;
F=round((NGris-1).*mat2gray(F,[0 255]));
X=0:255;
[N,Yhist]= hist(F(:),X);

%Calcular el valor promedio, desviación estandar y visibilidad;
promed=mean(double(F(:)));
des_std=std(double(F(:)));
visibilidad=StripesVisibility(F);

% Graficar


text_T=strcat({'NG promedio:','Desviación Estandar: ','Visibilidad: '},{num2str(promed)...
    ,num2str(des_std),num2str(visibilidad)});
text_x= 'Nivel de gris(8 bits [0 255])';
text_y='frecuencia del nivel de gris';

figurehist=bar(Yhist,N);axis on;xlim([0 255]);grid on;...
    title(text_T,'FontWeight','bold','FontSize',10,'FontName','Arial');...
    xlabel(text_x,'FontSize',8);ylabel(text_y,'FontSize',8);%drawnow

clear Yhist N
   

return