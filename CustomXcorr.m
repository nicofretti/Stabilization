function [stabilizedFrame,ang] = CustomXcorr(anchor,frame,angol)
    [R,C,~] = size(frame);
    %Trovo angolo e aggiorno il frame
    ang = findAngle(anchor,frame,angol);    
    frame = imrotate(frame,ang);
    
    %Trovo traslazione e aggiorno il frame
    cc = normxcorr2(anchor, frame);
    [max_cc, imax] = max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [(ypeak-size(frame,1)) (xpeak-size(frame,2))];
    stabilizedFrame = imtranslate(frame,[-(corr_offset(2)+round(C/2)),-(corr_offset(1)+round(R/2))],'FillValues',0);
    
end

function ang = findAngle(anchor,frame,angol)
    start = 0;
    stop = 360;
    if angol~=-1
        step=10;
        if angol<0
            start=0;
            stop=90;
        end
        if angol>=90 && angol<=180
            start=90;
            stop=180;
        end
        if angol>180 && angol<=270
            start=180;
            stop=270;
        end
        if angol>270
            start=270;
            stop=360;
        end
    end
    ang = testInRange(anchor,frame,start,stop,10);
    ang = testInRange(anchor,frame,ang-5,ang+5,1);
    fprintf("\n ANGOLO GREZZO: %d",ang); 
end

function a = testInRange(anchor,toRotate,startAng,stopAng,step)
    %Ritorna angolo con xcorr massima tra startAng e stopAng
    
    %Normalizzo toRotate
    a = startAng;
    ANGOLO = startAng;
    m = 0;
    while(ANGOLO <= stopAng)
        val = crossCorrWithAngle(toRotate,ANGOLO,anchor);
        if val >= m
            m = val;
            a = ANGOLO;
            if val == 1 || 1-val<=0.05
                break;
            end
        end
        ANGOLO= ANGOLO + step;
    end     
end


function m = crossCorrWithAngle(img,ang,anchor)
    irot  = imrotate(img,ang);
    crossCorr2 = normxcorr2(anchor,irot);
    [m,~] = max(crossCorr2(:));
end