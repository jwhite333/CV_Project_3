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

filter_sigma = 1.4;
Window_size = 5;
    

[original_img1, original_img2]=loadImage(option,setNumber);
inputImage1 = original_img1;
inputImage2 = original_img2;

for img_scale = 1:3

    figure(5 * img_scale - 4)
    imshow(inputImage1);
    figure(5 * img_scale - 3)
    imshow(inputImage2);
    
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
    [Ix,Iy] = imgradient(double(image2),'prewitt');
    
    % Temporal gradient
    It = double(image2-image1);
    
    % Loop through pixels on image
    figure(5 * img_scale - 2);
    imshow(inputImage2);
    hold on;
    W_center = ceil(Window_size/2.0);
    for x = W_center:(image2_dim(1)-W_center)+1
        for y = W_center:(image2_dim(2)-W_center)+1
            
            % Loop through W_size neighboring pixels
            A = zeros(2,2);
            b = zeros(2,1);
            counter = 1;
            for i = -(W_center-1):(W_center-1)
                for j = -(W_center-1):(W_center-1)
                    
                    % Build A and b matrices
                    A(1,1) = A(1,1) + Ix(x,y)^2;
                    A(2,2) = A(2,2) + Iy(x,y)^2;
                    A(2,1) = A(2,1) + Ix(x,y)*Iy(x,y);
                    A(1,2) = A(2,1);
                    b(1,1) = b(1,1) - Ix(x,y)*It(x,y);
                    b(2,1) = b(2,1) - Iy(x,y)*It(x,y);
                end
            end
            
            % Solve for [u,v] if point is a corner
            if round(det(A)) == 0
                
                % Get flow vector v
                v = A\b;

                % Find the magntidue
                magnitude(x,y) = sqrt(v(1,1)^2 + v(2,1)^2);
                
                %Find the angle
                angle(x,y) = atan2d(v(2,1), v(1,1));
            end
        end
    end
    
    % Show quiver plot
    figure(5*img_scale-1);
    [x,y] = meshgrid(1:image2_dim(2),1:image2_dim(1));
    u = cos(angle(:,:)).*magnitude(:,:);
    v = sin(angle(:,:)).*magnitude(:,:);
    quiver(x,y,u,v, 'color', [1,0,0],'Marker','.');
    
    % Normalize values
    min_angle = min(min(angle));
    max_angle = max(max(angle));
    angle = (angle+abs(min_angle))/(abs(min_angle)+max_angle);
    min_magnitude = min(min(magnitude));
    max_magnitude = max(max(magnitude));
    magnitude = (magnitude+abs(min_magnitude))/(abs(min_magnitude)+max_magnitude);
    
    hsv(:,:,1) = angle;
    hsv(:,:,2) = magnitude;
    hsv(:,:,3) = zeros(image1_dim(1),image1_dim(2));
    
    rgb_image2 = cat(3,double(inputImage2)/255,...
        double(inputImage2)/255,double(inputImage2)/255);
    color_image = rgb_image2;
    for x = 1:image2_dim(1)
        for y = 1:image2_dim(2)
            if hsv(x,y,1) ~= abs(min_angle)/(abs(min_angle)+max_angle) && ~isnan(hsv(x,y,1))
                test = hsv(x,y,:);
                color_image(x,y,:) = hsv(x,y,:);
            end
        end
    end

    figure(5 * img_scale);
    imshow(color_image);
    
    inputImage1 = impyramid(inputImage1, 'reduce');
    inputImage2 = impyramid(inputImage2, 'reduce');
    clear hsv;
    clear angle;
end
