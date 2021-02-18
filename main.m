clear all;
close all;
clc;


display("Inizio programma...");
video = VideoReader('shaky_car.avi');
nFrames = video.NumFrames;

firstFrame = video.readFrame();
[R,C,~] = size(firstFrame);

% Prendiamo l'ancora dall'immagine
figure; anchor = imcrop(firstFrame);
anchor = rgb2gray(anchor);
[aR,aC] = size(anchor);
close all;

% Inizio stabilizzazione dei frame
for i = 1:nFrames-1
    frame = video.readFrame();
    frame_gray = rgb2gray(frame);
    frames(:,:,:,i)=frame;
    corr_offset = CustomXcorr(anchor,frame_gray);
    new(:,:,:,i) = imtranslate(frame,[-(corr_offset(2)+round(C/2)),-(corr_offset(1)+round(R/2))],'FillValues',0);
end

output = VideoWriter('stabilized_video.mp4');
open(output);
for i=1:size(frames,4)
    writeVideo(output,new(:,:,:,i));
end
close(output);
display("Fine programma.");

