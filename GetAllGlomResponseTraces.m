function [GlomTraces, ROIList] = GetAllGlomResponseTraces(FolderPath,FrameIndices)

% get all files in the folder
AllFiles = dir([FolderPath,filesep,'O*_R*_s*.tif']);

% Get all ROIs
clear ROIs
if exist(fullfile(FolderPath,'GlomerularMasks.mat'))
    load(fullfile(FolderPath,'GlomerularMasks.mat'), 'ROIs');
end
ROIImage = ROIs;
clear ROIs
ROIList = unique(ROIImage);
ROIList(ROIList==0,:) = [];

% get traces for each glomerulus, each trial
GlomTraces = [];

for thisTrial = 1:numel(AllFiles) % every trial
    
    myTif = fullfile(AllFiles(thisTrial).folder,AllFiles(thisTrial).name);
    
    count = 0;
    MyStack = [];
    for frames = FrameIndices(1):FrameIndices(end)
        count = count + 1;
        MyFrame = double(imread(myTif, frames));
        MyStack(:,count) = MyFrame(:); % linearize the frame
    end
    
    for j = 1:numel(ROIList) % every ROI
        ROImask = find(ROIImage==ROIList(j));
        thisGlomTrace = mean(MyStack(ROImask,:));
        GlomTraces(j,1:length(thisGlomTrace),thisTrial) = thisGlomTrace;
    end
        
end

    

