% Shengke Xue, Zhejiang University, March 2017. 
% Contact information: see readme.txt
%% clear
clear;
close all;
clc;

%% addpath
addpath data ;
addpath load_func ;
addpath RPCA_func ;
addpath result ;
addpath util ;

%% define data path

currentPath = cd ;

% input path
imagePath = fullfile(currentPath, 'data') ;
load('COIL-20.mat', 'className');
userName = className;
classNum = numel(userName);

% output path
destDir = cell(classNum, 1);
destRoot = fullfile(currentPath, 'result', 'COIL') ;
for i = 1 : classNum
    destDir{i} = fullfile(destRoot, userName{i}) ;   
    if ~exist(destDir{i}, 'dir'),   mkdir(destRoot, userName{i}); end
end

%% define parameters

% dispaly flag
para.DISPLAY = 0 ;
para.DISPLAY = 1 ;

% save flag
para.saveStart = 1 ;
para.saveEnd = 1 ;
para.saveIntermedia = 0 ;

% for windows images
% para.imageSize = [ 32  32 ];
para.imageSize = [ 128  128 ];
               
% loop in RPCA
para.tol = 1e-7;       % stop iteration threshold
para.maxIter = 1000;   % maximum iteration
para.lambdac = 1 ;     % lambda = lambdac / sqrt(m) for ||E||_1

imageNum = 10;       % image number for each category
para.imageNum = imageNum;
para.classNum = classNum;
para.noise_ratio = 0.1;   % 0, 0.1, 0.2, 0.3

%% get image groups
[ ImageMat ] = get_images_COIL(imagePath, para);

%% start RPCA 
rpcaTimeElapsed = 0;
tic
for i = 1 : classNum
    disp( '--------------');
    disp(['begin RPCA ' userName{i}]);

    % RPCA, alignment batch images that belongs to the same category
    [Do, A, E, numIter] = RPCA_main(ImageMat{i}, para, destDir{i});
    
    % plot the results
    if para.DISPLAY
        layout.xI = ceil(sqrt(imageNum));
        layout.yI = ceil(imageNum / layout.xI) ;
        layout.gap = 2 ;
        layout.gap2 = 1 ;
        RPCA_plot(destDir{i}, para.imageNum, para.imageSize, layout);
    end     
end
fprintf('RPCA completes!\n');
rpcaTimeElapsed = toc

%% record test results
outputFileName = fullfile(destRoot, 'COIL_parameters.txt'); 
fid = fopen(outputFileName, 'a') ;
fprintf(fid, '****** %s ******\n', datestr(now,0));
fprintf(fid, '%s\n', ['image size: '  num2str(para.imageSize(1)) ' x ' num2str(para.imageSize(2)) ]);
fprintf(fid, '%s\n', ['image number: '  num2str(para.imageNum)  ]);
fprintf(fid, '%s\n', ['image class: '   num2str(para.classNum)  ]);
fprintf(fid, '%s\n', ['elapsed time: '  num2str(rpcaTimeElapsed)]);
fprintf(fid, 'parameters:\n');
fprintf(fid, '%s\n', ['  tolerance: '   num2str(para.tol)       ]);
fprintf(fid, '%s\n', ['  maxIter: '     num2str(para.maxIter)   ]);
fprintf(fid, '%s\n', ['  lambdac: '     num2str(para.lambdac)   ]);
fprintf(fid, '%s\n', ['  corrupt: '     num2str(para.noise_ratio)]);
fprintf(fid, '--------------------\n');
fclose(fid);