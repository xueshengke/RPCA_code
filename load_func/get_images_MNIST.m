function [imageMat] = get_images_MNIST( imagePath, para )
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
load(fullfile(imagePath, 'mnist_uint8.mat'));
trainNum = size(train_x, 1);
testNum = size(test_x, 1);

%% resize and normalize images
train_x = double(train_x) / 255;
train_y = double(train_y);
test_x = double(test_x) / 255;
test_y = double(test_y);

train_x = reshape(train_x, [trainNum imgSize(1) imgSize(2)]);
train_x = permute(train_x, [3 2 1]);
train_y = train_y';
[train_y, ~] = find(train_y == 1);
train_y = train_y';

test_x = reshape(test_x, [testNum imgSize(1) imgSize(2)]);
test_x = permute(test_x, [3 2 1]);
test_y = test_y';
[test_y, ~] = find(test_y == 1);
test_y = test_y';

%% images grouped to categories
imageMat = cell(1, classNum);
for i = 1 : classNum
    temp = train_x(:, :, train_y==i);
    randnum = randperm(size(temp, 3));
    imageMat{i} = temp(:, :, randnum(1:imageNum));
end

%% add corruptions on images
if ratio > 0
% add max value noises    
for i = 1 : classNum
    randnum = rand(imgSize(1), imgSize(2), imageNum);
    corrupt = randnum < ratio;
    maxVal = max(imageMat{i}(:));
    imageMat{i}(corrupt) = maxVal;
end

% add random value noises
% for i = 1 : classNum
%     randnum = rand(imgSize(1), imgSize(2), imageNum);
%     corrupt = randnum < ratio;
%     points = sum(corrupt(:)==1);
%     maxVal = max(imageMat{i}(:));
%     imageMat{i}(corrupt) = maxVal * rand(points, 1);
% end
end
