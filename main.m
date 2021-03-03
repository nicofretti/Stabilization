clear all;
close all;
clc;


display("Inizio programma...");
video = VideoReader('input\test_black.avi');
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
for i = 1:nFrames-1
    d.Value = i/nFrames;
    frame = video.readFrame();
    frame_gray = rgb2gray(frame);
    frames(:,:,:,i)=frame;
    [corr_offset,ang] = CustomXcorr(anchor,frame_gray);
    new(:,:,:,i) = imtranslate(frame,[-(corr_offset(2)+round(C/2)),-(corr_offset(1)+round(R/2))],'FillValues',0);
end
close(d);
output = VideoWriter('output.mp4');
open(output);
for i=1:size(frames,4)
    writeVideo(output,new(:,:,:,i));
end
close(output);
display("Fine programma.");

