clear all;
close all;
clc
template = double(rgb2gray(imread("template.jpg")));
fig = figure;
imagesc(template)
axis image off;
colormap gray;

%--
% Get ancor from image [xmin ymin width height]
ancor_mat = getrect();
rangeY = int32(ancor_mat(1):ancor_mat(1) + ancor_mat(3));
rangeX = int32(ancor_mat(2):ancor_mat(2) + ancor_mat(4));
rect = template(rangeX,rangeY);

figure();imagesc(rect);

%--
% Normalize image to mean
%normImg = template - mean(template(:));
normImg = template;
normAnchor = normImg(rangeX,rangeY);

%--
% Cross-correlation
crossCorr = xcorr2(normImg,normAnchor);

% Get position
[val,pos] = max(crossCorr(:)); %pos = valore dove xcorr è massimo
display(val);
%Traduco il valore di cross-corr prendendolo scorrendo la matrice ->
%[cc,rr]
[cc,rr] = ind2sub(size(crossCorr),pos);

% Dove la cross correlazione deve iniziare
r_X = cc - size(rect,1);
r_Y = rr - size(rect,2);

%Display
posing = template * 0.3;
posing(r_X + 1:cc, r_Y + 1:rr) = rect;

%figure;
%subplot(2,2,1);
%imagesc(template);
%axis image off;
%colormap gray;

%subplot(2,2,2);
imagesc(posing);
axis image off;
colormap gray;

%% REGOLA EMPIRICA
toRotate = double(rgb2gray(imread("storta.jpg")));
test = 0;
ang = 0;

%normTest = frame-mean(frame(:));
normTest = toRotate;
findAngle(normAnchor,normTest);

function ang = findAngle(anchor,toRotate)
    %Ritorna angolo di cui ruotare il frame per stabilizzarlo   
    ang = 0;
    rangeAngolo = [0,90]; %Inizio ricerca dicotomica
    STEPSDICOTOMICA = 15; %Iterazione dicotomica (quante volte divido a metà)
    a = crossCr(toRotate,0,anchor);
    b = crossCr(toRotate,90,anchor);
        
    q1 = abs(a - b);
    q2 = abs(crossCr(toRotate,90,anchor) - crossCr(toRotate,180,anchor));
    q3 = abs(crossCr(toRotate,180,anchor) - crossCr(toRotate,270,anchor));
    q4 = abs(crossCr(toRotate,270,anchor) - crossCr(toRotate,0,anchor));
    quadrante = max([q1,q2,q3,q4]);
    
    display(quadrante);
    
    switch quadrante
    case q2
        rangeAngolo = [90,180];
        a = b;
        b = crossCr(toRotate,180,anchor);
    case q3
        rangeAngolo = [180, 270];
        a = crossCr(toRotate,180,anchor);
        b = crossCr(toRotate,270,anchor);
    case q4
        rangeAngolo = [270,360];
        b = a;
        a = crossCr(toRotate,270,anchor);        
    end
    
    midValue = 0;
    %Ricerca dicotomica
    while(STEPSDICOTOMICA ~= 0)
        
        midAngle = rangeAngolo(1) + (abs(rangeAngolo(1) - rangeAngolo(2)) / 2);
        fprintf('Steps rimasti: %d - MidAngle: %.2f\n', STEPSDICOTOMICA, midAngle);
        
         midValue = crossCr(toRotate,midAngle,anchor);
         
         %Salvo arco con xcorr maggiore       TODO forse mettere abs
         if( abs(midValue - a) > abs(midValue - b) )             
             rangeAngolo(2) = midAngle;
             b = midValue;
         else
             rangeAngolo(1) = midAngle;
             a = midValue;
         end
         
        fprintf('Range calcolato: %.2f - %.2f\n', rangeAngolo(1), rangeAngolo(2));
        fprintf('-------------\n'); 
        
        STEPSDICOTOMICA = STEPSDICOTOMICA - 1;
    end 
  
    figure;
    subplot(1,3,1);
    imagesc(toRotate);
    
    subplot(1,3,2)
    imagesc(imrotate(toRotate,rangeAngolo(1)));
    
    subplot(1,3,3);
    imagesc(imrotate(toRotate,rangeAngolo(2)));
    
    colormap gray;
end

function m = crossCr(img,ang,anchor)
    img = imrotate(img,ang);
    imgNorm = img-mean(img(:));
    crossCorr2 = xcorr2(imgNorm,anchor);
    [m,~] = max(crossCorr2(:));
end

%for i=0:90
%    img = imrotate(frame,i);
%    normTest = img-mean(img(:));
%    crossCorr2 = xcorr2(normTest,normAnchor);
%    [val2,pos2] = max(crossCorr2(:));
%    if val2>=test || val2==val
%        ang=i;
%        test=val2;
%        display(i);
%    end
%end
%
%display(ang);
%figure;
%imagesc(imrotate(frame,ang));









