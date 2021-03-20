function [offset,ang] = CustomXcorr(C, R, anchor,frame,angol,tipo)
    %anchor --> riferimento rispetto a cui stabilzzare frame
    %frame --> il frame da stabilizzare rispetto ad anchor
    
    %Calcolo rotazione
    ang = findAngle(anchor,frame,angol,tipo);    
    frame = imrotate(frame,ang,'bilinear','crop'); 
    
    %Calcolo traslazione
    cc = normxcorr2(anchor,frame);
    [max_cc, imax] = max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    
    sizeAnchor = size(anchor);
    centerAnchor = [xpeak-round(sizeAnchor(2)/2),ypeak-round(sizeAnchor(1)/2)];
    offset = [R-centerAnchor(1),C-centerAnchor(2)];
end

function ang = findAngle(anchor,frame,angol,tipo)

    offset = 0; offset2 = 0;
    switch tipo
        case 1
            offset = 30; offset2 = 5; %7 + 10 controlli
        case 2 
            offset = 20; offset2 = 2; %5 + 4 controlli
        otherwise % tipo = 3, res > 1280*720
            offset = 10; offset2 = 1; %3 + 3 controlli
    end
    
    start = -offset + angol;
    stop = offset + angol;
    
    fprintf("\nRange [%d, %d]", start,stop);
    
    ang = testInRange(anchor, frame, start, stop, 10); %3 controlli
    ang = testInRange(anchor, frame, ang-offset2, ang+offset2, 1); %5 controlli 
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
            if val == 1 || (1-val) <= 0.05
                break;
            end
        end
        ANGOLO = ANGOLO + step;
    end     
end

function m = crossCorrWithAngle(img,ang,anchor)
    irot  = imrotate(img,ang, 'bilinear', 'crop');
    crossCorr2 = normxcorr2(anchor,irot);
    [m,~] = max(crossCorr2(:));
end