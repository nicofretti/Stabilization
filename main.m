clear all; close all; clc;

global R C; %Current video dimensions
global video nFrames anchor;
global fig sub1 sub2;
global btnFileChooser btnStabilizer

display("-Inizio programma");

% %%
% v1 = VideoReader(strcat(path, file));
% v2 = VideoReader('output.avi');
% fig = gcf;
% 
% ax1 = subplot(1,2,1, 'Parent', fig);
% title('Video originale');
% axis off; 
% 
% ax2 = subplot(1,2,2, 'Parent', fig);
% axis off; 
% for i = 1:nFrames-1
%   image(ax1, v1.read(i));
%   image(ax2, v2.read(i));
%   drawnow
% end

%Show GUI
createPanelAxisTitle();

function createPanelAxisTitle()
    global fig sub1 sub2 btnFileChooser btnStabilizer;
    
    % Create panel
    fig = figure();

    sub1 = subplot(1,2,1, 'Parent', fig);
    title('Original video');
    axis off; 
    
    sub2 = subplot(1,2,2, 'Parent', fig);
    title('Stabilized originale');
    axis off;    
       
    % Buttons
    btnFileChooser = uicontrol(fig,'unit','pixel','style','pushbutton','string','Choose video',...
            'position',[50 10 75 25], 'tag','PBButton123','callback',...
            {@chooseVideo});        
    
    btnStabilizer = uicontrol(fig,'unit','pixel','style','pushbutton','string','Stabilize',...
            'position',[140 10 75 25], 'tag','PBButton123','callback',...
            {@stabilizeVideo});
end

function chooseVideo(hObject,eventdata)
    global nFrames R C anchor video sub1 sub2;
    
    %Load file
    [file, path] = uigetfile('*');
    
    if(file ~=0) %Closed uigetfile      
        video = VideoReader(strcat(path, file));
        nFrames = video.NumFrames;

        % Load video dimensions
        firstFrame = video.readFrame();
        [R,C,~] = size(firstFrame);
        R = round(R/2);
        C = round(C/2);

        % Prendiamo l'ancora dall'immagine
        figure; anchor = imcrop(firstFrame);
        anchor = rgb2gray(anchor);

        image(sub1, video.read(1));
        image(sub2, zeros(size(firstFrame)));
        close;
    end

    
end

 function stabilizeVideo(hObject,eventdata) 
    global nFrames sub2 video R C anchor btnStabilizer;
    
    set(btnStabilizer, 'Enable', 'off');
 
   % Inizio stabilizzazione dei frame
    %fig = uifigure;
    %d = uiprogressdlg(fig,'Title','Attendere');
    %drawnow
    ang = 0;
    for i = 1:nFrames-1    
        display(i/nFrames);
        %d.Value = i/nFrames; % Progress bar    
        %d.Message = 'Frame analizzati ' + sprintf("%d",i) + '/' + sprintf("%d",nFrames);

        frame = video.readFrame();
        [offset,ang] = CustomXcorr(R,C,anchor,rgb2gray(frame),ang,i);
        stabilizedFrame = imtranslate(imrotate(frame,ang,'bilinear','crop')...
            ,offset,'FillValues',0);
        
        image(sub2, stabilizedFrame);

        videoOutput(:,:,:,i) = stabilizedFrame; %add stabilized frame to video output  
    end

    %close(fig);
    display("Output file...");
    % Write stabilized video
    output = VideoWriter('output');
    open(output);
    for i=1:nFrames-1
        writeVideo(output,mat2gray(videoOutput(:,:,:,i)));
    end
    display("Done");
    close(output);
    
    set(btnStabilizer, 'Enable', 'on');
end