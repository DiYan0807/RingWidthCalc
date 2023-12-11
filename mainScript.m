% This is the main script to identify the Zring peaks and calculate the ring width

% input: structures created in MicrobeJ

% set up some parameters in the first section for filtering out the low
% intensity peaks, low-frequency background, combining the loose peaks.

% output: the result is automatically saved in the same structure with new
% fields. The images of the cell and intensity profile are saved to a tiff
% file.

% by Di Yan, 2023-12-11

%% section 1. setup parameters
minP = 40;         % Threshold for minimum peak intensity, used for findpeaks(Intensity_pass,'MinPeakHeight',minP ,...)
D = 35;            % Threshold of the minimum distance between two rings, used for zringpeakfinder(Intensity_pass,minP,D); in pixel
fpass = 0.003;     % Threshold for the highpass filter. used for highpass(Intensity_final,fpass,1,'steepness',0.95);

%% section 2: load the result from MicrobeJ structure, like example1-WT-20-40.mat

% select single or multiple structures to process
[filename pathname] = uigetfile('.mat','Select the cell segment result from MicrobeJ','MultiSelect','on');
if ~iscell(filename)
    FilenameA{1} = filename;
else
    FilenameA = filename;
end
NumFile = length(FilenameA);
% process the files one by one
for ind_F = 1 : NumFile
    FileTemp = FilenameA{ind_F};
    Dotposi1 = find(FileTemp == '.');
    Dotposi = Dotposi1(end);
    FileSave = ['RingImages-' FileTemp(1:Dotposi) 'tif']; % filename for saving the image
    load([pathname FileTemp]);
    all_cell = Experiment.Bacteria; % get the intensity profiles
    Cellnum = length(all_cell);
    
 % initiate intermediate variables
    Profile = []; % To save the fluorescence profile along the medial line
    ImageC = [];% To save the image of the ROI(cell)
    All_pks = [];%To save the intensity of the peak after combined
    All_locs = [];% To save the location of the peak after combined
    All_ws = [];% To save the width of the peak after combined
    Peak_number = [];%To save the number of the peaks after combined
    Mean_cell_len = [];%To save the mean cell length (Cell_length/Peak_number)
    All_cell_len = [];%To save cell length in many times according to the number of peak in a cell
    Cell_length = [];% To save all of the cell length in one time
    Cell_Index = [];%To save the index of cell, cell number(column 1), zring number(column 2).
 % initate the variable to save the results
    All_Data = []; %cell number(column1); zring number in one cell(column2); width(column3); peak Intensity(column4); peak location(column5);cell length corresponding to zring(column6)
 
 % process the cell one-by-one
    for ic = 1 : Cellnum
        Medial_temp = all_cell(ic).medial; % temporary variable of medial line data
        Im_temp = all_cell(ic).PROFILE_MEDIAL; % temporary variable of image data
        Medial_len = length(Medial_temp); % the length of the medial line of the cell, in pixels
        Cell_length = [Cell_length;Medial_len];
        for im = 1 : Medial_len
            Intensity_P(im,1) = Medial_temp(im).INTENSITY.ch1; % note: you need to change the ch1 or ch2 according to the channel with fluorescence
        end
        Im_P = Im_temp.ch(1).pixel; % note: you need to change ch(1) to ch(2) or others if the channel of fluorescence is the other.
        Im_P_trans = Im_P';  %Transpose row and colume
        Profile(ic).Intensity_P = Intensity_P;
        ImageC(ic).Im_P = Im_P;
        
        [fitresult, gof] = Zringfit(Intensity_P); %         % fit the data with two gaussian peaks. This is just for visulization
        
        % filter the intensity profile and find the peaks
        Intensity_raw = Profile(ic).Intensity_P;
        Intensity_final = Intensity_raw - min(Intensity_raw);
        Intensity_pass = highpass(Intensity_final,fpass,1,'steepness',0.95);
        [pks,locs,ws] = zringpeakfinder(Intensity_pass,minP,D);
        
        
        % plot the peaks and their width       
        W_left = [];
        W_right = [];
        ip = length(pks);
        Mean_len = Medial_len/ip;
        Mean_cell_len = [Mean_cell_len;Mean_len];
        Peak_number = [Peak_number;ip];
        for il = 1:ip
            All_cell_len = [All_cell_len;Medial_len];
            Cell_Index = [Cell_Index;ic,il];
            W_left = [W_left;locs(il,1)-ws(il,1)/2];
            W_right = [W_right;locs(il,1)+ws(il,1)/2];
        end
        
        % plot the fitting
        h = figure( 'Name', ['Zringfit-' int2str(ic)] );
        ax1 = subplot(3,1,1);
        axis equal;
        imagesc(Im_P_trans);
        xline(locs);
        xline(W_left,'--r');
        xline(W_right,'--r');
        ax2 = subplot(3,1,2);
        set(h,'Visible','Off') % hide the plot from showing
        plot( fitresult, [1:Medial_len], Intensity_P);
        hold on
        plot([1:Medial_len], smooth(Intensity_P,3),'k-');
        title(['cell-' num2str(ic)  ' R = ' num2str(gof.adjrsquare)]);
        legend('off');
        ax3 = subplot(3,1,3);
        plot(Intensity_final);
        hold on
        plot(Intensity_pass);
        findpeaks(Intensity_pass,'MinPeakHeight',minP,'Annotate','extents','WidthReference','halfheight');
        xline(locs);
        xline(W_left,'--r');
        xline(W_right,'--r');
        title(['Number of peak-' num2str(ip)  ' Threshold of peak = ' num2str(minP)]);
        legend('off');
        linkaxes([ax1,ax2,ax3],'x');
        W(ic,1) = min([fitresult.c1,fitresult.c2]); % sigma of the ring
        R(ic,1) = gof.adjrsquare; % adjusted R^2 of the fitting
        saveas(h,'temp.jpg');
        Imtemp = imread('temp.jpg');
        imwrite(Imtemp,[pathname FileSave],'WriteMode','Append');
        
        clear Intensity_P Im_P Im_P_trans
        close(h)
 % combine all the results from one cell       
        All_pks = [All_pks;pks];
        All_locs = [All_locs;locs];
        All_ws = [All_ws;ws];
% show the progress        
        display(['Processing file = ' num2str(ind_F) ' ...']);
        display(['Processing cell = ' num2str(ic) ' ...']);
    end
% save all the data in the All_Data variable 
    All_Data(:,1:2) = Cell_Index; %the file index and cell index 
    All_Data(:,3) = All_ws;       %the ring width
    All_Data(:,4) = All_pks;      %the peak heights
    All_Data(:,5) = All_locs;     %the peak locations
    All_Data(:,6) = All_cell_len; %the cell length
    save([pathname FileTemp], 'Experiment','All_Data');
    clear Experiment R W Profile All_pks All_locs All_ws Peak_number Mean_cell_len All_cell_len Cell_length Cell_Index All_Data;
end
display('fitting finished');