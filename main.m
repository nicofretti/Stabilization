clear all; close all; clc;

display("Inizio programma...");

video = VideoReader('input\0.avi');
nFrames = video.NumFrames;

firstFrame = video.readFrame();
[R,C,~] = size(firstFrame);
R = round(R/2);
C = round(C/2);
% Prendiamo l'ancora dall'immagine
figure; anchor = imcrop(firstFrame);
anchor = rgb2gray(anchor);

close all;

% Inizio stabilizzazione dei frame
fig = uifigure;
d = uiprogressdlg(fig,'Title','Attendere');
drawnow
ang = 0;
for i = 1:nFrames-1
    d.Value = i/nFrames; %progress bar
    d.Message = 'Frame analizzati '+sprintf("%d",i)+'/'+sprintf("%d",nFrames);
    frame = video.readFrame();
    [offset,ang] = CustomXcorr(R,C,anchor,rgb2gray(frame),ang,i);
    stabilizedFrame = imtranslate(imrotate(frame,ang,'bilinear','crop')...
        ,offset,'FillValues',0);
    %add stabilized frame to video output
    videoOutput(:,:,:,i) = stabilizedFrame;    
end
close(fig);
output = VideoWriter('output');
open(output);

for i=1:nFrames-1
    writeVideo(output,mat2gray(videoOutput(:,:,:,i)));
end
close(output);
%%
v1 = VideoReader('input\0.avi');
v2 = VideoReader('output.avi');
fig = gcf;
ax1 = subplot(2,2,1, 'Parent', fig);
axis off ; 
ax2 = subplot(2,2,2, 'Parent', fig);
axis off ; 
for i = 1:nFrames-1
  image(ax1, v1.read(i));
  image(ax2, v2.read(i));
  drawnow
end
display("Fine programma");

