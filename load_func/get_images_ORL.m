function [imageMat] = get_images_ORL( imagePath, para )
%--------------------------------------------------------------------------
% Xue Shengke, Zhejiang University, March 2017.
% Contact information: see readme.txt
%--------------------------------------------------------------------------
%     load images of COIL dataset
% 
%     Inputs:
%         imagePath          -- path where image data exists
%         para               -- patameters for loading the dataset
% 
%     Outputs:
%         imageMat           -- image matrix categories
%--------------------------------------------------------------------------
%% read parameters from para
imageNum = para.imageNum;
imgSize  = para.imageSize;
classNum = para.classNum;
ratio    = para.noise_ratio;

%% load original data from *.mat file
load(fullfile(imagePath, 'extendedORL.mat'));

%% images grouped to categories
imageMat = cell(classNum, 1);
for i = 1 : classNum
    images = orlData{i}.images;
    images = images / 255;
    images = imresize(images, [imgSize(1) imgSize(2)]);
    imageNumActual = size(images, 3);
    if imageNumActual < imageNum
        fprintf('ERROR: class %d, images are not enough, %d < %d \n', ...
            i, imageNumActual, imageNum);
        return ; 
    end    
    randnum = randperm(imageNumActual);    
    imageMat{i} = images(:, :, randnum(1:imageNum));
end

%% add corruptions on images
if ratio > 0
% add max value noises
% for i = 1 : classNum
%     randnum = rand(imgSize(1), imgSize(2), imageNum);
%     corrupt = randnum < ratio;
%     maxVal = max(imageMat{i}(:));
%     imageMat{i}(corrupt) = maxVal;
% end

% add random value noises
for i = 1 : classNum
    randnum = rand(imgSize(1), imgSize(2), imageNum);
    corrupt = randnum < ratio;
    points = sum(corrupt(:)==1);
    maxVal = max(imageMat{i}(:));
    imageMat{i}(corrupt) = maxVal * rand(points, 1);
end

end
