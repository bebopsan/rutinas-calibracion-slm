load ('12Medidas.mat');
M1=rgb2gray(M1);
M1=double(M1);
M1=(M1/255)*4;
M2=rgb2gray(M2);
M2=double(M2);
M2=(M2/255)*4;
M3=rgb2gray(M3);
M3=double(M3);
M3=(M3/255)*4;
M4=rgb2gray(M4);
M4=double(M4);
M4=(M4/255)*4;

in(:,1)=reshape(M1,1,size(M1,2)*size(M1,1));
in(:,2)=reshape(M2,1,size(M2,2)*size(M2,1));
in(:,3)=reshape(M3,1,size(M3,2)*size(M3,1));
in(:,4)=reshape(M4,1,size(M4,2)*size(M4,1));

B=sum(sum(in(:,:))/(size(in,1)*size(in,2)));

insb(:,:)=in-B;

C=insb'*insb;
[U,D,V]=svd(C);

Y1=insb*V(:,1);
Y2=insb*V(:,2);
%Y1=V(:,1)*insb;
%Y2=V(:,2)*insb;

% Ysort=sort(Y(:),'descend');
% u=Ysort(1)
% for n=1:size(Ysort,1)
% if Ysort(n)==u
%     Ysort(n)=0;
% end
% end
% v=max(Ysort)

phi=atan2(Y2,Y1);
phiim=reshape(phi,size(M1,1),size(M1,2));
figure,imagesc(phiim),colormap(gray);
figure,imagesc(phi),colormap(gray);