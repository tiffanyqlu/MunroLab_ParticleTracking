function interpolatedPathVals = straightenPath(im,pixelList)
%straightenPath  takes a list of pixels defining a path and straightens
%them.  Returns interpolated pixels on the path


    len = size(pixelList,3);
    width = size(pixelList,2);
    nInd = len*width;
    
    interpolatedPathVals = zeros(len,size(im,3));
    
    p1X = reshape(floor(pixelList(1,:,:)),1,nInd);
    p1Y = reshape(floor(pixelList(2,:,:)),1,nInd);
    p2X = p1X + 1;
    p2Y = p1Y + 1;
    lamX = reshape(pixelList(1,:,:),1,nInd) - p1X;
    lamY = reshape(pixelList(2,:,:),1,nInd) - p1Y;
    
    
    x1y1 = sub2ind([size(im,1),size(im,2)],p1Y,p1X);
    x2y1 = sub2ind([size(im,1),size(im,2)],p1Y,p1X);
    x1y2 = sub2ind([size(im,1),size(im,2)],p1Y,p1X);
    x2y2 = sub2ind([size(im,1),size(im,2)],p1Y,p1X);
    
    for i = 1:size(im,3)
        frm = cast(im(:,:,i),'double');
        xInt1 = frm(x1y1).*(1-lamX) + frm(x2y1).*lamX;
        xInt2 = frm(x1y2).*(1-lamX) + frm(x2y2).*lamX;
        iVals = xInt1.*(1-lamY) + xInt2.*lamY;
        tmp = reshape(iVals,width,len);
        interpolatedPathVals(:,i) = mean(tmp);
    end
        

end

