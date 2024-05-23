function [Ratio, ImageSize] = GetRatioImage_FA(ImageFileName, StimulusFrameSettings, FrameWindow)

if nargin<3
    FrameWindow = [10 10];
end

myTif = fullfile(ImageFileName.folder,ImageFileName.name);
TifInfo = imfinfo(myTif);

ImageSize = [TifInfo(1).Height, TifInfo(1).Width];
ZeroFrame = zeros(ImageSize(1),ImageSize(2));

% Air Frames
whichFrames = [(StimulusFrameSettings(1) - FrameWindow(1) + 1): StimulusFrameSettings(1)];
AirFrame =  ZeroFrame;
for x = 1:numel(whichFrames) 
    AirFrame = AirFrame + ...
        double(imread(myTif, whichFrames(x)));
end
% average it
AirFrame = AirFrame/x;

% Stimulus Frames
whichFrames = [(StimulusFrameSettings(1)+1): (StimulusFrameSettings(1)+FrameWindow(2))];
OdorFrame =  ZeroFrame;
for x = 1:numel(whichFrames) 
    OdorFrame = OdorFrame + ...
        double(imread(myTif, whichFrames(x)));
end
% average it
OdorFrame = OdorFrame/x;

Ratio = (OdorFrame - AirFrame)./AirFrame;


