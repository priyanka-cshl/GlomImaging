function varargout = GlomerularResponseViewer(varargin)
% GLOMERULARRESPONSEVIEWER MATLAB code for GlomerularResponseViewer.fig
%      GLOMERULARRESPONSEVIEWER, by itself, creates a new GLOMERULARRESPONSEVIEWER or raises the existing
%      singleton*.
%
%      H = GLOMERULARRESPONSEVIEWER returns the handle to a new GLOMERULARRESPONSEVIEWER or the handle to
%      the existing singleton*.
%
%      GLOMERULARRESPONSEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLOMERULARRESPONSEVIEWER.M with the given input arguments.
%
%      GLOMERULARRESPONSEVIEWER('Property','Value',...) creates a new GLOMERULARRESPONSEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GlomerularResponseViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GlomerularResponseViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GlomerularResponseViewer

% Last Modified by GUIDE v2.5 23-May-2024 13:58:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GlomerularResponseViewer_OpeningFcn, ...
    'gui_OutputFcn',  @GlomerularResponseViewer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GlomerularResponseViewer is made visible.
function GlomerularResponseViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GlomerularResponseViewer (see VARARGIN)

% Choose default command line output for GlomerularResponseViewer
handles.output = hObject;

% defaults
handles.TrialSequence = [];
handles.ImageSize = [];
%addpath(genpath('/Users/Priyanka/Desktop/github_local/matlabUtils/'));
handles.GlomTraces = [];
handles.ROIList = [];

handles.FilterImage.Value = 1;

handles.currCoords = [];

%colormap(brewermap([],'*RdBu'));
axes(handles.axes1);
set(gca, 'XTick', [], 'YTick', []);
axis manual;
axes(handles.axes4);
set(gca, 'XTick', [], 'YTick', []);
axis manual;
axes(handles.axes6);
set(gca, 'XTick', [], 'YTick', []);
axis manual;
axes(handles.axes7);
set(gca, 'XTick', [], 'YTick', []);
axis manual;
handles.MyImage = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GlomerularResponseViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GlomerularResponseViewer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in LoadSession.
function [handles] = LoadSession_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.ImagingPath.String)
    [ImagingDir] = uigetdir('','Select Imaging data folder');
    if isequal(ImagingDir,0)
    else
        handles.ImagingPath.String = ImagingDir;
    end
end
AllFiles = dir([handles.ImagingPath.String,filesep,'O*_R*_s*.tif']);
StimulusList = arrayfun(@(i) sscanf(AllFiles(i).name,'O%f_R%f_s%f',[1 3]), ...
    1:numel(AllFiles), 'UniformOutput', false);
StimulusList = reshape(cell2mat(StimulusList),3,[])'; % odor IDs, Repeat#, stimulus#

handles.OdorList.String = cellstr(num2str(unique(StimulusList(:,1))));
handles.OdorList.Max = 1;
handles.RepeatList.String = cellstr(num2str(unique(StimulusList(:,2))));
handles.RepeatList.Max = numel(unique(StimulusList(:,2)));
handles.RepeatList.Value = 1; %[1:handles.RepeatList.Max];

% update stimulus settings
framecounts = sscanf(AllFiles(1).name,'O%f_R%f_s%f_%f_%f_%f',[1 6]);
framecounts(:,1:3) = []; % pre-odor, odor, post-odor
handles.StimulusSettings.Data = [framecounts(1) framecounts(1)+[1 framecounts(2)] framecounts(3)]';
handles.FrameWindow.Data = repmat(framecounts(2),[2 1]);

handles.TrialSequence = StimulusList;

ROIs = [];
% Load ROIs
if exist(fullfile(handles.ImagingPath.String,'AllGloms.mat'))
    load(fullfile(handles.ImagingPath.String,'AllGloms.mat'), 'GlomSession');
    ROIs = GlomSession.ROImasks;
elseif exist(fullfile(handles.ImagingPath.String,'GlomerularMasks.mat'))
    load(fullfile(handles.ImagingPath.String,'GlomerularMasks.mat'), 'ROIs');
end

if ~isempty(ROIs)
    handles.MyImage(:,:,3) = ROIs;
    handles.ROIcount.String = num2str(numel(unique(handles.MyImage(:,:,3)))-1);
    handles.MyImage(:,:,4) = 0*handles.MyImage(:,:,3);
    handles.currCoords = [];

    axes(handles.axes4);
    handles.I3 = imagesc(0*ROIs);
    handles.I3.AlphaData = 0*ROIs;
    colormap(handles.axes4,brewermap(numel(unique(handles.MyImage(:,:,3)))-1,'*Set1'));
    handles.axes4.Color = 'none';
    set(handles.I3,'ButtonDownFcn', {@thisROICallback, handles, hObject});
    set(gca, 'XTick', [], 'YTick', []);
end

% Update handles structure
guidata(hObject, handles);

updateROIs(hObject, [], handles);
%     guidata(hObject, handles);
%     updateROIs(hObject, [], handles);


% --- Executes on button press in LoadSelectTrials.
function LoadSelectTrials_Callback(hObject, eventdata, handles)
% hObject    handle to LoadSelectTrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
whichOdor      = str2num(cell2mat(handles.OdorList.String(handles.OdorList.Value)));
whichReps       = str2num(cell2mat(handles.RepeatList.String(handles.RepeatList.Value)));

% find all trials that match this condition
AllReps = [];
for n = 1:numel(whichReps)
    %     MyTrials = vertcat(MyTrials, ...
    %         find(ismember(handles.TrialSequence(:,1:2),[whichOdor whichReps(n)],'rows')) );
    ImageFileName = dir(fullfile(handles.ImagingPath.String,['O',num2str(whichOdor),'_R',num2str(whichReps(n)),'*.tif']));
    [Ratio, ImageSize] = GetRatioImage_FA(ImageFileName, handles.StimulusSettings.Data, handles.FrameWindow.Data);
    
    if handles.FilterImage.Value
        % Band-pass filtering of the image (removes both large and small structures)
        % Low-pass filtering (removes small structures/noise)
        LowPass         = imgaussfilt(Ratio,handles.FilterSettings.Data(1));
        HighPass        = imgaussfilt(Ratio,handles.FilterSettings.Data(2));
        FilteredImage   = LowPass - HighPass;
        Ratio = FilteredImage;
    end
    
    if isempty(AllReps)
        AllReps = Ratio;
        handles.ImageSize = ImageSize;
    else
        AllReps = AllReps + Ratio;
    end
end
Ratio = AllReps/n;

axes(handles.axes1);
handles.MyImage(:,:,1) = Ratio;
handles.MyImageHandle = imagesc(Ratio(:,:,1));
colormap(handles.axes1,brewermap([],'*RdBu'));

% Draw traces for all gloms
if exist(fullfile(handles.ImagingPath.String,'AllGloms.mat'))
    load(fullfile(handles.ImagingPath.String,'AllGloms.mat'), 'GlomSession');
    %ROIs = GlomSession.ROImasks;
    GlomTraces = GlomSession.Traces;
else


[GlomTraces, handles.ROIList] = GetGlomTraces(handles.MyImage(:,:,3),...
                [], ...
                handles.ImagingPath.String, ...
                handles.ImageSize, ...
                handles.TrialSequence(MyTrials,[3 5 6 7 8]), ...
                handles.FrameWindow.Data);
end
axes(handles.axes6);
%typicalResponse = mode(max()); 
nROIs = size(GlomTraces,1);
taxis = size(GlomTraces,2) - 10;
hold off
plot(GlomTraces(:,1:taxis,2)'+ repmat(0.1*(1:nROIs)',1,taxis)')
yLim = get(gca,'YLim');

% draw stimulus box
StimStart = handles.StimulusSettings.Data(1);
StimStop = StimStart + handles.StimulusSettings.Data(3) - handles.StimulusSettings.Data(2) + 1;
fill([StimStart StimStart StimStop StimStop], [yLim(1) yLim(2) yLim(2) yLim(1)], [0.8 0.8 0.8],...
    'EdgeColor', 'none', 'FaceAlpha', 0.5);
hold on
plot(GlomTraces(:,1:taxis,2)'+ repmat(0.1*(1:nROIs)',1,taxis)');
set(gca,'XTick',[], 'XLim',[0 taxis], 'YTick', []);

handles.GlomTraces = GlomTraces;

% Update handles structure
guidata(hObject, handles);

function thisROICallback(object_handle, ~, handles, hObject)
handles = guidata(hObject);
axes_handle  = get(object_handle,'Parent');
coordinates = round(get(axes_handle,'CurrentPoint'));

switch get(gcf,'SelectionType')
    case 'normal'
        currCoords = fliplr(coordinates(1,1:2));
        whichROI = handles.MyImage(currCoords(1),currCoords(2),3);
        if whichROI
            thisROI = 0*handles.MyImage(:,:,4);
            thisROI(find(handles.MyImage(:,:,3)==whichROI)) = 0.5;
            handles.MyImage(:,:,4) = thisROI;
            
            ROIidx = find(handles.ROIList == whichROI);
            axes(handles.axes7);
            taxis = size(handles.GlomTraces,2) - 10;
            hold off
            plot(handles.GlomTraces(ROIidx,1:taxis,2));
            yLim = get(gca,'YLim');
            
            % draw stimulus box
            StimStart = handles.StimulusSettings.Data(1);
            StimStop = StimStart + handles.StimulusSettings.Data(3) - handles.StimulusSettings.Data(2) + 1;
            fill([StimStart StimStart StimStop StimStop], [yLim(1) yLim(2) yLim(2) yLim(1)], [0.8 0.8 0.8],...
                'EdgeColor', 'none', 'FaceAlpha', 0.5);
            hold on
            plot(handles.GlomTraces(ROIidx,1:taxis,2));
            set(gca,'XTick',[], 'XLim',[0 taxis], 'YTick', []);
        end
        guidata(hObject, handles);
        handles = updateROIs(hObject, [], handles);
    otherwise
end

% Update handles structure
guidata(hObject, handles);

% fill up ROIs
% Threshold_Callback(hObject, [], handles);

% --- Executes when entered data in editable cell(s) in ImageScale.
function ImageScale_CellEditCallback(hObject, eventdata, handles)
NewScale = flipud(handles.ImageScale.Data(:,2));
axes(handles.axes1);
set(gca,'CLim',NewScale);

% Update handles structure
guidata(hObject, handles);


function Threshold_Callback(hObject, eventdata, handles)
%        str2double(get(hObject,'String')) returns contents of Threshold as a double
MyThresh = str2double(handles.Threshold.String);
ThreshedImage = ones(handles.ImageSize(1), handles.ImageSize(2));
ThreshedImage(find(handles.MyImage(:,:,1)>MyThresh)) = 0; % all responsive areas will be dark
handles.MyImage(:,:,2) = ThreshedImage;
GreyImage = handles.MyImage(:,:,1);
GreyImage(find(handles.MyImage(:,:,1)>MyThresh)) = MyThresh; % all responsive areas will be saturated
axes(handles.axes2);
%handles.I2 = imagesc(logical(ThreshedImage));
handles.I2 = imagesc(GreyImage);
colormap(handles.axes2,brewermap([],'Greys'));
set(gca, 'XTick', [], 'YTick', []);

% Update handles structure
guidata(hObject, handles);

updateROIs(hObject, [], handles);

function newROICallback(object_handle, ~, handles, hObject)
handles = guidata(hObject);
axes_handle  = get(object_handle,'Parent');
coordinates = round(get(axes_handle,'CurrentPoint'));

switch get(gcf,'SelectionType')
    case 'normal' % Click left mouse button.
        handles.currCoords = fliplr(coordinates(1,1:2));
        guidata(hObject, handles);
        handles = updateROIs(hObject, [], handles);
    otherwise
end

% Update handles structure
guidata(hObject, handles);

function Image2Callback(object_handle, ~, handles, hObject)
handles = guidata(hObject);
axes_handle  = get(object_handle,'Parent');
coordinates = round(get(axes_handle,'CurrentPoint'));

switch get(gcf,'SelectionType')
    case 'normal' % Click left mouse button.
        handles.currCoords = fliplr(coordinates(1,1:2));
        guidata(hObject, handles);
        handles = updateROIs(hObject, [], handles);
    case 'extend'  %Center-click or shift + click
        currCoords = fliplr(coordinates(1,1:2));
        whichROI = handles.MyImage(currCoords(1),currCoords(2),3);
        if whichROI
            thisROI = 0*handles.MyImage(:,:,4);
            thisROI(find(handles.MyImage(:,:,3)==whichROI)) = 0.5;
            handles.MyImage(:,:,4) = thisROI;
            allROIs = handles.MyImage(:,:,3);
            allROIs(find(handles.MyImage(:,:,3)==whichROI)) = 0;
            handles.MyImage(:,:,3) = allROIs;
            handles.ROIcount.String = num2str(numel(unique(handles.MyImage(:,:,3)))-1);
        end
        guidata(hObject, handles);
        handles = updateROIs(hObject, [], handles);
    otherwise
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function [handles] = updateROIs(hObject, eventdata, handles)

if ~isempty(handles.currCoords)
    tempImage   = imfill(logical(handles.MyImage(:,:,2)), handles.currCoords);
    roiImage    = 0.5*(tempImage - handles.MyImage(:,:,2));
    handles.MyImage(:,:,4) = roiImage;
end

axes(handles.axes4);
if size(handles.MyImage,3)>2
    allROIs = -handles.MyImage(:,:,4) + logical(handles.MyImage(:,:,3));
else
    allROIs = 0*handles.MyImage(:,:,1);
end
handles.I3.CData = allROIs;
handles.I3.AlphaData = ceil(allROIs);
colormap(handles.axes4,brewermap(3,'*Set1'));
handles.axes4.Color = 'none';

% Update handles structure
guidata(hObject, handles);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(hObject);
OldThresh = str2double(handles.Threshold.String);
ThresholdStep = 0.01;
NewThresh = OldThresh;
switch get(gcf,'CurrentCharacter')
    case 'q'
        NewThresh = OldThresh - 10*ThresholdStep;
    case 'e'
        NewThresh = OldThresh + 10*ThresholdStep;
    case 'a'
        NewThresh = OldThresh - ThresholdStep;
    case 'd'
        NewThresh = OldThresh + ThresholdStep;
    case 'z'
        NewThresh = OldThresh - ThresholdStep/10;
    case 'c'
        NewThresh = OldThresh + ThresholdStep/10;
    case 't'
        % add current ROI to ROI list
        handles.MyImage(:,:,3)  = (1+max(max(handles.MyImage(:,:,3))))*ceil(handles.MyImage(:,:,4)) + handles.MyImage(:,:,3);
        handles.MyImage(:,:,4)  = 0*handles.MyImage(:,:,4);
        handles.ROIcount.String = num2str(numel(unique(handles.MyImage(:,:,3)))-1);
        handles.currCoords = [];
        guidata(hObject, handles);
        updateROIs(hObject, [], handles);
    otherwise
end

if NewThresh~=OldThresh
    handles.Threshold.String = num2str(NewThresh);
    guidata(hObject, handles);
    Threshold_Callback(hObject, [], handles);
end




% --- Executes on button press in SaveROIs.
function SaveROIs_Callback(hObject, eventdata, handles)
% hObject    handle to SaveROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ROIs = squeeze(handles.MyImage(:,:,3));
save(fullfile(handles.ImagingPath.String,'GlomerularMasks.mat'), 'ROIs');


% --- Executes on button press in OverlayROIs.
function OverlayROIs_Callback(hObject, eventdata, handles)
if handles.OverlayROIs.Value
    handles.I3.AlphaData = ceil(handles.I3.CData);
else
    handles.I3.AlphaData = handles.I3.AlphaData*0;
end
guidata(hObject, handles);
