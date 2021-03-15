clear all; close all; clc;

display("Inizio programma...");
video = VideoReader('input\shaky_car.avi');
nFrames = video.NumFrames;

firstFrame = video.readFrame();
[R,C,~] = size(firstFrame);

% Prendiamo l'ancora dall'immagine
figure; anchor = imcrop(firstFrame);
anchor = rgb2gray(anchor);

display(size(anchor));

[aR,aC] = size(anchor);
close all;
display(nFrames);

% Inizio stabilizzazione dei frame
fig = uifigure;
d = uiprogressdlg(fig,'Title','Attendere');
drawnow
ang = -1000;
for i = 1:nFrames-1
    %d.Value = i/nFrames; %progress bar
    frame = video.readFrame();
        
    frames(:,:,:,i) = frame;
    frame_gray = rgb2gray(frame);
    %f = zeros(350,350);
    [stabilizedFrame,ang] = CustomXcorr(round(R/2),round(C/2),...
        anchor,frame_gray,ang,i);
    
    %add black padding to stabilized image
    %m = min(240,size(tmp,1));
    %n = min(135,size(tmp,2));
    %f(1:m,1:n) = tmp(1:m,1:n); 
    
    %add stabilized frame to video output
    videoOutput(:,:,:,i) = stabilizedFrame;    
end
close(d);
output = VideoWriter('output.mp4');
open(output);

for i=1:size(frames,4)
    writeVideo(output,mat2gray(videoOutput(:,:,:,i)));
end
close(output);
display("Fine programma.");

