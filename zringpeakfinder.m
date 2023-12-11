function [pks,locs,ws] = zringpeakfinder(Intensity_pass,a,D)
%zringpeakfinder find peaks in a cell intensity profile :Intensity_pass
%the peaks have at least a height and separated by D in location.

% pks is a vector of the height of all the peaks detected
% locs is a vector of the locations of the peaks (close peaks are combined
% and the location is the avergae location
% w is the width of all the peaks. combined peaks will be from
% [locs(1)-w(1)/2,locs(end)+w(end)/2];

% 1. agjust the intensity profile to be above zero
Intensity_final = Intensity_pass; % - min(Intensity_pass);
% 2. detect all the peaks first
[pk,loc,w,p] = findpeaks(Intensity_final,'MinPeakHeight',a,'WidthReference','halfheight');
% 3. search for the close peaks and combine them
pks = [];
locs = [];
ws = [];
% find the distance between consecutive peaks
if length(loc) == 1 % if there is only one peak, it is the final result
    pks = pk;
    locs = loc;
    ws = w;
else if length(loc) == 0 % if there is no peak, the result is "10000"
        pks = 10000;
        locs = 10000;
        ws = 10000;
    else % otherwise, we need to find which peaks are close
        Dlocs = diff(loc);
        Dlarge = find(Dlocs > D); % find all the positions of distant peaks.
        Dlarge = [0;Dlarge;length(loc)]; % add the last frame as the border
        % for example, if Dlarge(1) = 1, the distance between peak1 and peak2 is big enough
        for ii = 1 : length(Dlarge)-1
            Index_temp = [Dlarge(ii)+1: Dlarge(ii+1)]; % the peaks within the distance D
            loc_temp = loc(Index_temp); % the locations
            w_temp = w(Index_temp); % the widths
            B_l = loc_temp(1)-w_temp(1)/2; % left of the new peak
            B_r = loc_temp(end)+w_temp(end)/2;% right of the new peak
            w_new = B_r - B_l; % the new width
            pk_new = max(pk(Index_temp)); % use the highest peak as the new peak
            loc_new = mean(loc_temp); % the peak location is the center of all the peaks in the range D
            pks = [pks;pk_new];
            locs = [locs;loc_new];
            ws = [ws;w_new];
        end
    end
end


