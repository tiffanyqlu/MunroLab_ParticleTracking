function [ ] = showTrajectories(in,trks,lineWidth)



    nTrks = length(trks);
    xaxis = size(in,1);
    yaxis = size(in,2);

    iMax = max(max(in));
    iMin = min(min(in));

    fig = figure;
    fig.InnerPosition = [100 100 xaxis yaxis];
    axes('Position',[0 0 1 1]);

    imshow(in,[iMin 0.5*iMax]); 
    axis image;
    hold on;

    for iTrk = 1:nTrks
        plot(trks(iTrk).x(1),trks(iTrk).y(1),'Marker','o','MarkerEdgeColor', 'c','MarkerSize',3);
        plot(trks(iTrk).x(1:trks(iTrk).lifetime),trks(iTrk).y(1:trks(iTrk).lifetime),'m','LineWidth',lineWidth); % split
    end
end

