clear all; close all; clc;

display("Inizio programma...");
video = VideoReader('input\test_black.mp4');
nFrames = video.NumFrames;

firstFrame = video.readFrame();
[R,C,~] = size(firstFrame);

% Prendiamo l'ancora dall'immagine
figure; anchor = imcrop(firstFrame);
anchor = rgb2gray(anchor);
[aR,aC] = size(anchor);
close all;
display(nFrames);

% Inizio stabilizzazione dei frame
fig = uifigure;
d = uiprogressdlg(fig,'Title','Please Wait');
drawnow
ang = -1;
for i = 1:nFrames
    d.Value = i/nFrames;
    frame = video.readFrame();
    frame_gray = rgb2gray(frame);
    frames(:,:,:,i) = frame;
    %1080x1920
    f = zeros(1147,1957);
    [tmp,ang] = CustomXcorr(anchor,frame_gray,ang);
    m = min(1147,size(tmp,1));
    n = min(1957,size(tmp,2));
    f(1:m,1:n)= tmp(1:m,1:n); 
    new(:,:,:,i) =  f; %Stabilized frame
end
close(d);
output = VideoWriter('PROVAA.mp4');
open(output);
for i=1:size(frames,4)
    writeVideo(output,new(:,:,:,i));
end
close(output);
display("Fine programma.");

