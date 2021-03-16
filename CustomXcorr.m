function [offset,ang] = CustomXcorr(C, R, anchor,frame,angol,i)
    %anchor --> riferimento rispetto a cui stabilzzare frame
    %frame --> il frame da stabilizzare rispetto ad anchor
          
    %Trovo angolo di cui ruotare, ruoto il frame
    ang = findAngle(anchor,frame,angol);    
    frame = imrotate(frame,ang,'bilinear','crop'); 
    
    cc = normxcorr2(anchor,frame);
    [max_cc, imax] = max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    
    sizeAnchor = size(anchor);
    centerAnchor = [xpeak-round(sizeAnchor(2)/2),ypeak-round(sizeAnchor(1)/2)];
    offset = [R-centerAnchor(1),C-centerAnchor(2)];
       
    %subplot(221); imagesc(anchor); axis image; title('Ancora scelta');
    %subplot(222); imagesc(frame); axis image;  title(strcat('Immagine originale: ', num2str(i)));
    %hold on; 
    %scatter(xpeak, ypeak,'rX');
    %scatter(centerAnchor(1), centerAnchor(2));
    %subplot(224); imshow(stabilizedFrame); title('Immagine stabilizzata');  
    %pause(0.025);
end

function ang = findAngle(anchor,frame,angol)
    start = -10 + angol;
    stop = 10 + angol;
    
    ang = testInRange(anchor,frame,start,stop,10); % 3 controlli
    ang = testInRange(anchor,frame,ang-2,ang+2,1); % 5 controlli 
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
    irot  = imrotate(img,ang, 'bilinear', 'crop');
    crossCorr2 = normxcorr2(anchor,irot);
    [m,~] = max(crossCorr2(:));
end