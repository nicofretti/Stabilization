function stabilizedFrame = CustomXcorr(anchor,frame)

    %Trovo angolo e aggiorno il frame
    ang = findAngle(anchor,frame);    
    frame = imrotate(frame,ang);
    
    %Trovo traslazione e aggiorno il frame
    cc = normxcorr2(anchor, frame);
    [max_cc, imax] = max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [(ypeak-size(frame,1)) (xpeak-size(frame,2))];
    stabilizedFrame = imtranslate(frame,[-(corr_offset(2)+round(C/2)),-(corr_offset(1)+round(R/2))],'FillValues',0);
    
end

function ang = findAngle(anchor,frame)
    ang = testInRange(anchor,frame,0,360,10);
    ang = testInRange(anchor,frame,ang-5,ang+5,1);
end

function a = testInRange(anchor,toRotate,startAng,stopAng,step)
    %Ritorna angolo con xcorr massima tra startAng e stopAng
    
    %Normalizzo toRotate
    a = startAng;
    ANGOLO = startAng;
    m = 0;
    while(ANGOLO ~= stopAng+1)
        val = crossXCorrAng(toRotate,ANGOLO,anchor);
        if val >= m
            m = val;
            a = ANGOLO;
            display(val);
            if val == 1
                break;
            end
        end
        ANGOLO= ANGOLO + step;
        fprintf("\nStep:%d",ANGOLO);
    end
    fprintf("\n ANGOLO GREZZO: %d",a);      
end


function m = crossXCorrAng(img,ang,anchor)
    img = imrotate(img,ang);
    imgNorm = img-mean(img(:));
    crossCorr2 = xcorr2(imgNorm,anchor);
    [m,~] = max(crossCorr2(:));
end