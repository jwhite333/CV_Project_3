% Parameters
filter_sigma = 1.4;
Window_size = 5;
W_sigma = 7;
W_weights = fspecial('gaussian',Window_size^2,W_sigma);
W = diag(diag(W_weights));
k = 0.04;           % Value for Harris corner detector

% Load images (Saved as grayscale so no conversion necessary)
image1 = imgaussfilt(imread('images/toys1.gif'),filter_sigma);
image2 = imgaussfilt(imread('images/toys2.gif'),filter_sigma);
image1_dim = size(image1);
image2_dim = size(image2);
if image1_dim ~= image2_dim     % Sanity check
    error("Input image dimentions are not the same. Aborting");
end

% Create result image
of_image = zeros(image1_dim(1),image1_dim(2));

% Gradient of image 2
[Ix,Iy] = imgradient(image2);

% Temporal gradient
It = int8(image2-image1);

% Loop through pixels on image
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
            quiver(y,x,v(1,1),v(2,1));
            hold on;
        end
    end
end
        