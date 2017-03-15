function [ D, A, E, numIter ] = RPCA_main( batchImages, para, destDir )
%--------------------------------------------------------------------------
% Xue Shengke, Zhejiang University, March 2017.
% Contact information: see readme.txt
%--------------------------------------------------------------------------
%     RPCA main
% 
%     Inputs:
%         batchImages       --- train images
%         para              --- parameters for RPCA
%         destDir           --- save directory
% 
%     Outputs: 
%         D                 --- output aligned images
%         A                 --- low-rank component
%         E                 --- sparse error
%         numIter           --- number of iterations
%--------------------------------------------------------------------------
%% get the initial input images in standard frame
numImages = para.imageNum;
imgSize = para.imageSize; 
D = zeros(imgSize(1)*imgSize(2), numImages);

for i = 1 : numImages
    y = reshape(batchImages(:, :, i), [prod(imgSize) 1]);
    y = y / norm(y) ;
    D(:, i) = y ;
end

%% save inital D and tau
if para.saveStart
    save(fullfile(destDir, 'original.mat'), 'D') ;
end

%% start the main loop
lambda = para.lambdac / sqrt(size(D,1)); 
tic
%% RPCA inner loop -----------------------------------------     
[A, E, numIter] = RPCA_iALM(D, lambda, para.tol, para.maxIter);

timeConsumed = toc
rankA = rank(A);
E_0 = length(find(abs(E)>0));
disp(['rank(A) ' num2str(rankA) ', ||E||_0 ' num2str(E_0) ', number of iterations ' num2str(numIter)]);

%% save the optimization results

Do = D;
if para.saveEnd
    save(fullfile(destDir, 'final.mat'), 'Do', 'A', 'E');
end

outputFileName = fullfile(destDir, 'results.txt'); 
fid = fopen(outputFileName, 'a') ;
fprintf(fid, '%s\n', ['align images: '     num2str(numImages)    ]) ;
fprintf(fid, '%s\n', ['total iterations: ' num2str(numIter)      ]) ;
fprintf(fid, '%s\n', ['elapsed time: '     num2str(timeConsumed) ]) ;
fprintf(fid, '%s\n', ['parameters:']) ;
fprintf(fid, '%s\n', ['   lambda: ' num2str(para.lambdac) ' / sqrt(' num2str(para.imageSize(1)) ')']) ;
fprintf(fid, '%s\n', ['   stop condition: '    num2str(para.tol)     ]) ;
fprintf(fid, '%s\n', ['   maximum iteration: ' num2str(para.maxIter) ]) ;
fprintf(fid, '--------------------------------\n') ;
fclose(fid);