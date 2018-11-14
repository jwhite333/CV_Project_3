function [image1, image2] = loadImage(option, setNumber)
switch option
    case 1
        if (setNumber == 1)
            path1 = 'images/LKTest1im1.pgm';
            path2 = 'images/LKTest1im2.pgm';
        elseif (setNumber == 2)
            path1 = 'images/LKTest2im1.pgm';
            path2 = 'images/LKTest2im2.pgm';
        elseif (setNumber == 3)
            path1 = 'images/LKTest3im1.pgm';
            path2 = 'images/LKTest3im2.pgm';
        else
            error("Error");
        end
    case 2
        if (setNumber == 1)
            path1 = 'images/toys1.gif';
            path2 = 'images/toys2.gif';
        elseif (setNumber == 2)
            path1 = 'images/toys21.gif';
            path2 = 'images/toys22.gif';
        else
            error("Error");
        end
    otherwise
        error("Error");
end
image1 = imread(path1);
image2 = imread(path2);

end
    