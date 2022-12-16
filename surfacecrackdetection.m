function oImage = surfacecrackdetection(Image)


[Image_Height,Image_Width,Number_Of_Colour_Channels] = size(Image);

Block_Size = 50;
Number_Of_Blocks_Vertically = floor(Image_Height/Block_Size);
Number_Of_Blocks_Horizontally = floor(Image_Width/Block_Size);
Image_Blocks = struct('Blocks',[]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Calculating Global Threshold%%%%%%%%%%%%
% We be used to segment the Crack from image
[counts,x] = imhist(im2gray(Image),16);
T = otsuthresh(counts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Here we will make small
%%%% Blocks and process each bolck
Index = 1;
for Row = 1: +Block_Size: Number_Of_Blocks_Vertically*Block_Size
    for Column = 1: +Block_Size: Number_Of_Blocks_Horizontally*Block_Size
        
    Row_End = Row + Block_Size - 1;
    Column_End = Column + Block_Size - 1;
        % To make sure that we don't overflow the image boundary
        % Every time it does we will reset to to strart again
    if Row_End > Image_Height
       Row_End = Image_Height;
    end
    
    if Column_End > Image_Width
       Column_End = Image_Width;
    end
    % Taking small block
    Temporary_Tile = Image(Row:Row_End,Column:Column_End,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%% Now That we have Single Frame we will Now Perform the RGB Channel Sepration
    process_img =Temporary_Tile;
    % Seprating RGB channels
    r = process_img(:,:,1);
    g = process_img(:,:,2);
    b = process_img(:,:,3);
    test = rgb2gray(process_img);
    dummy = test;
    sz = size(test);
    % Adjusting the constrast
    gs = imadjust(dummy);
    %
   % [counts,x] = imhist(dummy,16);
%stem(x,counts)
    %T = otsuthresh(counts);
    H = fspecial("average",21);
    gssmooth = imfilter(dummy,H,"replicate");


    %BW = imbinarize(gssmooth,min(0.19,T));

% Image segmentation
    test(test < min(70,255*T)) = 0;
    test(test >= min(70,255*T)) = 255;
    detected = 255*uint8(~test);
    detected=medfilt2(detected);
    avg = fspecial('average' , 49);
    detected=imfilter(detected,avg);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cost = sum(detected , 2);
    %cost2 = sum(detected , 1);
    if sum(cost) > 15000
        % detecting weather image is with crack 
        %disp('Fault Detected')
        % Heighlighting the crack 
        im = cat(3,r,g+detected,b);
        %imshow(detected,[]);title('Crack Detected');
    else
        im = cat(3,r,g,b);

    end% read image from datastore


    oImage(Row:Row_End,Column:Column_End,:) = im;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    end  
end

end
