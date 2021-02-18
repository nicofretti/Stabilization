function [corr_offset] = CustomXcorr(anchor,frame)
    cc = normxcorr2(anchor, frame);
    [max_cc, imax]=max((cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [(ypeak-size(frame,1)) (xpeak-size(frame,2))];
end