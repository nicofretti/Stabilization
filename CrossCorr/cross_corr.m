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
inputs = double(rgb2gray(imread("storta2.jpg")));
test = 0;
ang = 0;

normTest = inputs-mean(inputs(:));
%normTest = toRotate;
findAngle(normAnchor,normTest);

%% FUNCTIONS
function ang = findAngle(anchor,toRotate)
    %Ritorna angolo di cui ruotare il frame per stabilizzarlo   
    ang = 0;
    rangeAngolo = [0,90]; %Inizio ricerca dicotomica
    STEPSDICOTOMICA = 15; %Iterazione dicotomica (quante volte divido a metà)
    a = crossCorrWithAngle(toRotate,0,anchor);
    b = crossCorrWithAngle(toRotate,90,anchor);
        
    q1 = abs(a - b);
    q2 = abs(b - crossCorrWithAngle(toRotate,180,anchor));
    q3 = abs(crossCorrWithAngle(toRotate,180,anchor) - crossCorrWithAngle(toRotate,270,anchor));
    q4 = abs(crossCorrWithAngle(toRotate,270,anchor) - a);
    quadrante = max([q1,q2,q3,q4]);
    fprintf("0: %d\n90: %d\n180: %d\n270:%d\n",a,b,crossCorrWithAngle(toRotate,180,anchor),crossCorrWithAngle(toRotate,270,anchor));
    
    
    
    switch quadrante
    case q2
        rangeAngolo = [90,180];
        a = b;
        b = crossCorrWithAngle(toRotate,180,anchor);
    case q3
        rangeAngolo = [180, 270];
        a = crossCorrWithAngle(toRotate,180,anchor);
        b = crossCorrWithAngle(toRotate,270,anchor);
    case q4
        rangeAngolo = [270,360];
        b = a;
        a = crossCorrWithAngle(toRotate,270,anchor);        
    end
    
    midValue = 0;
    %Ricerca dicotomica
    while(STEPSDICOTOMICA ~= 0)
        
        midAngle = rangeAngolo(1) + (abs(rangeAngolo(1) - rangeAngolo(2)) / 2);
        fprintf('Steps rimasti: %d - [%.2f,%.2f] -> MidAngle: %.2f\n', STEPSDICOTOMICA,rangeAngolo(1),rangeAngolo(2), midAngle);
        
         midValue = crossCorrWithAngle(toRotate,midAngle,anchor);
         
         %Salvo arco con xcorr maggiore       TODO forse mettere abs
         if( abs(midValue - a) > abs(midValue - b) )             
             rangeAngolo(2) = midAngle;
             b = midValue;
         else
             rangeAngolo(1) = midAngle;
             a = midValue;
         end
         
        
        fprintf('-------------\n'); 
        
        STEPSDICOTOMICA = STEPSDICOTOMICA - 1;
    end 
    fprintf('Range finale [%.2f, %.2f]\n', rangeAngolo(1), rangeAngolo(2));
    figure;
    subplot(1,2,1);
    imagesc(toRotate);
    
    subplot(1,2,2)
    imagesc(imrotate(toRotate,rangeAngolo(1)));
    
    colormap gray;
end

function m = crossCorrWithAngle(img,ang,anchor)
    img = imrotate(img,ang);
    imgNorm = img-mean(img(:));
    crossCorr2 = xcorr2(imgNorm,anchor);
    [m,~] = max(crossCorr2(:));
end








