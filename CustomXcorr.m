function [corr_offset,ang] = CustomXcorr(anchor,frame)
    ang = findAngle(anchor,frame);
    
    %cc = normxcorr2(anchor, frame);
    %[max_cc, imax]=max((cc(:)));
    %[ypeak, xpeak] = ind2sub(size(cc),imax(1));
    %corr_offset = [(ypeak-size(frame,1)) (xpeak-size(frame,2))];
end

function ang = findAngle(anchor,frame)
    range = [abs(crossCr(frame,0,normAnchor)-crossCr(frame,90,normAnchor)),abs(crossCr(frame,90,normAnchor)- crossCr(frame,180,normAnchor)),abs(crossCr(frame,180,normAnchor)- crossCr(frame,270,normAnchor)),abs(crossCr(frame,270,normAnchor)-crossCr(frame,0,normAnchor))]
    display(mex(range));
end


function m = crossXCorrAng(img,ang,anchor)
    img = imrotate(img,ang);
    imgNorm = img-mean(img(:));
    crossCorr2 = xcorr2(imgNorm,anchor);
    [m,~] = max(crossCorr2(:));
end