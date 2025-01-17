clear all; close all; clc;

global R C; %Current video dimensions
global video nFrames anchor firstFrame videoStart;
global fig sub1 sub2;
global btnFileChooser btnStabilizer btnReplay;
global path file;
global tipo;

fprintf("-Inizio programma\n");
%Show GUI
createPanelAxisTitle();

function createPanelAxisTitle()
    global fig sub1 sub2 btnFileChooser btnStabilizer btnReplay;
    
    % Create panel
    fig = figure('Resize','off');

    sub1 = subplot(1,2,1, 'Parent', fig); %Original video
    axis off;
    
    sub2 = subplot(1,2,2, 'Parent', fig); %Stabilized video
    axis off;
       
    % Buttons
    btnFileChooser = uicontrol(fig,'unit','pixel','style','pushbutton','string','Scegli video',...
            'position',[50 10 75 25], 'tag','PBButton123','callback',...
            {@chooseVideo});        
    
    btnStabilizer = uicontrol(fig,'unit','pixel','style','pushbutton','string','Stabilizza',...
            'position',[140 10 75 25],'callback',...
            {@stabilizeVideo});
    
    btnReplay = uicontrol(fig,'unit','pixel','style','pushbutton','string','Riproduci',...
            'position',[350 10 75 25],'callback',...
            {@replayVideo});
        
    % Labels
    uicontrol(fig,'unit','pixel','style','text','string','Video originale',...
            'position',[125 390 100 25], 'FontSize', 11);
        
    uicontrol(fig,'unit','pixel','style','text','string','Video stabilizzato',...
        'position',[350 390 170 25], 'FontSize', 11);
    

    set(btnReplay, 'Enable', 'off');
    set(btnStabilizer, 'Enable', 'off');
end

function chooseVideo(hObject,eventdata)
    global tipo nFrames videoStart firstFrame btnReplay btnStabilizer file path R C anchor video sub1 sub2;
    set(btnReplay, 'Enable', 'off');
    %Load file
    [file, path] = uigetfile('*');
            
    if(file ~=0) %Closed uigetfile      
        video = VideoReader(strcat(path, file));
        nFrames = video.NumFrames;

        % Load video data
        firstFrame = video.readFrame();
        videoStart = video.CurrentTime;
        [R,C,~] = size(firstFrame);
        
        %Check risoluzione
        res = R*C; 
        tipo = 3;% res > 1280*720
        if( res < 640*480) tipo = 1; end;
        if( res >= 640*480 && res < 1280*720) tipo = 2; end;    
        
        display(tipo);
        
        R = round(R/2);
        C = round(C/2);
        
        set(btnStabilizer, 'Enable', 'on')
        image(sub1, video.read(1));
    end    
end

 function stabilizeVideo(hObject,eventdata) 
    global tipo nFrames path videoStart file fig sub1 sub2 video R C anchor firstFrame btnStabilizer ...
        btnReplay;

    % Prendiamo l'ancora dall'immagine
    figure; anchor = imcrop(firstFrame);
    close;
    anchor = rgb2gray(anchor);    
    
    set(btnStabilizer, 'Enable', 'off');
    set(btnReplay, 'Enable', 'off');
    
    %Inizio stabilizzazione dei frame
    video.CurrentTime = videoStart;
    ang = 0;
    f = waitbar(0,"Attendere la stabilizzazione 0/0");
    for i = 1:nFrames-1
        text = sprintf('Attendere la stabilizzazione %d/%d',i,nFrames);
        waitbar(i/nFrames,f,text);
        
        frame = video.readFrame();
        [offset,ang] = CustomXcorr(R,C,anchor,rgb2gray(frame),ang,tipo);
        stabilizedFrame = imtranslate(imrotate(frame,ang,'bilinear','crop'),offset,'FillValues',0);
        
        videoOutput(:,:,:,i) = stabilizedFrame; %add stabilized frame to video output  
    end

    close(f);
    
    % Write stabilized video
    output = VideoWriter('output');
    open(output);
    for i=1:nFrames-1
        writeVideo(output,mat2gray(videoOutput(:,:,:,i)));
    end
    fprintf("\nDone...\n");
    close(output);
    v1 = VideoReader(strcat(path, file));
    v2 = VideoReader('output.avi');
    for i = 1:nFrames-1
      image(sub1, v1.read(i));
      image(sub2, v2.read(i)); 
      drawnow
    end
    set(btnStabilizer, 'Enable', 'on');
    set(btnReplay, 'Enable', 'on');
 end

 function replayVideo(hObject,eventdata)
    global nFrames file path sub1 sub2;
    v1 = VideoReader(strcat(path, file));
    v2 = VideoReader('output.avi');
    for i = 1:nFrames-1
      image(sub1, v1.read(i));
      image(sub2, v2.read(i));
      drawnow
    end
 end