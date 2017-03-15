function [imageMat] = get_images_dummy( imagePath, para )
%--------------------------------------------------------------------------
% Xue Shengke, Zhejiang University, March 2017.
% Contact information: see readme.txt
%--------------------------------------------------------------------------
%     load images of MNIST dataset
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
load(fullfile(imagePath, 'dummy_face.mat'), 'dummyData');

%% resize and normalize images
normDummy = cell(classNum, 1);
for i = 1 : classNum
    tmp = dummyData / 255;
    totalNum = size(dummyData, 3);
    tmp = reshape(tmp, [prod(imgSize) totalNum]);
    maxVal = max(tmp);
    tmp = tmp ./ repmat(maxVal, [prod(imgSize) 1]);
    tmp = reshape(tmp, [imgSize(1) imgSize(2) totalNum]);
    normDummy{i} = imresize(tmp, [imgSize(1) imgSize(2)]);
end

%% images grouped to categories
imageMat = cell(classNum, 1);
for i = 1 : classNum
    images = normDummy{i};
    imageNumActual = size(images, 3);
    if imageNumActual < imageNum 
        fprintf('ERROR: class %d, images are not enough, %d < %d !\n', ...
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
    randnum(:, :, 1:0.8*imageNum) = 1;
    corrupt = randnum < ratio;
    points = sum(corrupt(:)==1);
    maxVal = max(imageMat{i}(:));
    imageMat{i}(corrupt) = maxVal * rand(points, 1);
end

end
