function [seguir,CamProperties]=cameraproperties(vid,val_Brightness,val_Contrast,val_Gain,val_BacklightCompensation,val_Exposure)

%default val.. hay que actualizarlos
val_Brightness =255;
val_Contrast = 0;
% val_FrameRate = 8.0000;
val_Gain = 0;
val_BacklightCompensation ='off';
val_Exposure = -8;
seguir=12;

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

CamProperties=get(src);%Le puse punto y coma para que haya más rápido el proceso y no pierda tiempo en mostrar los valores
%Le borro de la memoria para que cuando la vuelva a llamar necesariamente
%tenga quer volver a leerla y actualice los valores.
clear cameraproperties
return



