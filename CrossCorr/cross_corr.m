clear all;
close all;
clc
template =  double(rgb2gray(imread("template3.jpg")));
fig = figure;
imagesc(template)
axis image off;
colormap gray;

%--
% Get ancor from image [xmin ymin width height]
ancor_mat = getrect();
rangeY = int32(ancor_mat(1):ancor_mat(1)+ancor_mat(3));
rangeX = int32(ancor_mat(2):ancor_mat(2)+ancor_mat(4));
rect = template(rangeX,rangeY);

%--
% Normalize image to mean
normImg = template-mean(template(:));
normAnchor = normImg(rangeX,rangeY);

%--
% Cross-correlation
crossCorr = xcorr2(normImg,normAnchor);

% Get position
[val,pos] = max(crossCorr(:)); %pos = valore dove cross-corr è massimo
display(val);
%Traduco il valore di cross-corr prendendolo scorrendo la matrice ->
%[cc,rr]
[cc,rr] = ind2sub(size(crossCorr),pos);

% Dove la cross correlazione deve iniziare
r_X = cc - size(rect,1);
r_Y = rr - size(rect,2);

%Display
posing = template*0.3;
posing(r_X+1:cc,r_Y+1:rr)=rect;

%figure;
%subplot(2,2,1);
%imagesc(template);
%axis image off;
%colormap gray;

subplot(2,2,2);
imagesc(posing);
axis image off;
colormap gray;

%% REGOLA EMPIRICA
frame = double(rgb2gray(imread("template33.jpg")));
test=0;
ang=0;

normTest = frame-mean(frame(:));
findAngle(normAnchor,normTest);


function ang = findAngle(anchor,frame)
    ang = 0;
    q1=abs(crossCr(frame,0,anchor)-crossCr(frame,90,anchor));
    q2=abs(crossCr(frame,90,anchor)- crossCr(frame,180,anchor));
    q3=abs(crossCr(frame,180,anchor)- crossCr(frame,270,anchor));
    q4=abs(crossCr(frame,270,anchor)-crossCr(frame,0,anchor));
    display(max([q1,q2,q3,q4]));
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









