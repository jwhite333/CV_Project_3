% Parameters
clc;
clear;


% Image input selection
% option
% 1 = LKTest1im
% 2 = Toys
option = 1;

% setNumber
% For LKTest1im
% 1 = LKTest1im1 & LKTest1im2
% 2 = LKTest2im1 & LKTest2im2
% 3 = LKTest3im1 & LKTest3im2
% For Toys
% 1 = toys1 & toys2
% 2 = toys21 & toys22
setNumber = 2;

[inputImage1, inputImage2]=loadImage(option,setNumber);

for index = 1:3
    
    figure(4*index - 3)
    imshow(inputImage1);
    figure(4 * index - 2)
    imshow(inputImage2);
    
    
    filter_sigma = 1.4;
    Window_size = 20;
    W_sigma = 7;
    W_weights = fspecial('gaussian',Window_size^2,W_sigma);
    W = diag(diag(W_weights));
    k = 0.04;           % Value for Harris corner detector
    
    % Load images (Saved as grayscale so no conversion necessary)
    image1 = imgaussfilt(inputImage1,filter_sigma);
    image2 = imgaussfilt(inputImage2,filter_sigma);
    image1_dim = size(image1);
    image2_dim = size(image2);
    if image1_dim ~= image2_dim     % Sanity check
        error("Input image dimentions are not the same. Aborting");
    end
    
    % Create result image
    of_image = zeros(image1_dim(1),image1_dim(2));
    angle = zeros(image1_dim(1),image1_dim(2));
    magnitude = zeros(image1_dim(1),image1_dim(2));
    
    % Gradient of image 2
    [Ix,Iy] = imgradient(image2);
    
    % Temporal gradient
    It = int8(image2-image1);
    
    % Loop through pixels on image
    figure(4 * index - 1);
    imshow(image2);
    hold on;
    W_center = ceil(Window_size/2.0);
    for x = W_center:(image2_dim(1)-W_center)+1
        for y = W_center:(image2_dim(2)-W_center)+1
            
            % Loop through W_size neighboring pixels
            A = zeros(Window_size^2,2);
            b = zeros(Window_size^2,1);
            counter = 1;
            for i = -(W_center-1):(W_center-1)
                for j = -(W_center-1):(W_center-1)
                    
                    % Build A and b matrices
                    A(counter,:) = [Ix(x+i,y+j),Iy(x+i,y+j)];
                    b(counter,1) = -It(x+i,y+j);
                    counter = counter + 1;
                end
            end
            
            % Solve for [u,v] if point is a corner
            if round(det(A'*W^2*A)) ~= 0
                v = (A'*W^2*A)\(A'*W^2*b);
                quiver(y,x,v(1,1),v(2,1), 'color', [1,0,0]);
                hold on;
                
                % Color Code
                % Find the magntidue
                magnitude(x,y) = sqrt(v(1,1)^2 + v(2,1)^2);
                %Find the angle
                angle(x,y) = atan2d(v(2,1), v(1,1));
            end
        end
    end
    hold off;
    
    hsv(:,:,1) = normalize(angle, 'range');
    hsv(:,:,2) = normalize(magnitude, 'range');
    hsv(:,:,3) = ones(image1_dim(1),image1_dim(2));
    
    image = hsv2rgb(hsv);
    figure(4 * index);
    imshow(image);
    
    inputImage1 = impyramid(inputImage1, 'reduce');
    inputImage2 = impyramid(inputImage2, 'reduce');
    clear hsv;
    clear angle;
    clear ones;
end
