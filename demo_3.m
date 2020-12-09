gclear;
fprintf('   ******   Side Window Filtering   ******\n');
fprintf('        Demo 3 -- Image Colorization\n');

img_out = cell(1, 8);

%% Test 1
img1_original = double(imread('test_images/color1.bmp')) / 255;
img1_marked = double(imread('test_images/color1_marked.bmp')) / 255;
img_out{1} = img1_original;
img_out{2} = img1_marked;
img_size_1 = size(img1_original, 1:2);

% extract the mark area and mark color
img1_color = sum(abs(img1_original - img1_marked), 3) > 0.01;
img1_color = double(img1_color);

% change to YIQ(ntsc) color mode
YIQ1_gray = rgb2ntsc(img1_original);
YIQ1_color = rgb2ntsc(img1_marked);

% make a new image, Y is the grayscale value, UV define color
YUV1(:, :, 1) = YIQ1_gray(:, :, 1);
YUV1(:, :, 2:3) = YIQ1_color(:, :, 2:3);

% colorized the image
img_out{3} = colorize(img1_color, YUV1, 3, false);
img_out{3} = abs(ntsc2rgb(img_out{3}));
fprintf('Process 1/4 finished.\n');

% colorized the image (side window)
img_out{4} = colorize(img1_color, YUV1, 3, true);
img_out{4} = abs(ntsc2rgb(img_out{4}));
fprintf('Process 2/4 finished.\n');

%% Test 2
img2_original = double(imresize(imread('test_images/color2.bmp'), 0.5, 'nearest')) / 255;
img2_marked = double(imresize(imread('test_images/color2_marked.bmp'), 0.5, 'nearest')) / 255;
img_out{5} = img2_original;
img_out{6} = img2_marked;
img_size_2 = size(img2_original, 1:2);

% extract the mark area and mark color
img2_color = sum(abs(img2_original - img2_marked), 3) > 0.01;
img2_color = double(img2_color);

% change to YIQ(ntsc) color mode
YIQ2_gray = rgb2ntsc(img2_original);
YIQ2_color = rgb2ntsc(img2_marked);

% make a new image, Y is the grayscale value, UV define color
YUV2(:, :, 1) = YIQ2_gray(:, :, 1);
YUV2(:, :, 2:3) = YIQ2_color(:, :, 2:3);

% colorized the image
img_out{7} = colorize(img2_color, YUV2, 3, false);
img_out{7} = abs(ntsc2rgb(img_out{7}));
fprintf('Process 3/4 finished.\n');

% colorized the image (side window)
img_out{8} = colorize(img2_color, YUV2, 3, true);
img_out{8} = abs(ntsc2rgb(img_out{8}));
fprintf('Process 4/4 finished.\n');

%% Show and save results
% count detail area
detail_1_1 = int32(img_size_1(1)*0.27): int32(img_size_1(1)*0.39);
detail_1_2 = int32(img_size_1(2)*0.19): int32(img_size_1(2)*0.31);
detail_2_1 = int32(img_size_1(1)*0.73): int32(img_size_1(1)*0.85);
detail_2_2 = int32(img_size_1(2)*0.20): int32(img_size_1(2)*0.32);
detail_3_1 = int32(img_size_2(1)*0.23): int32(img_size_2(1)*0.35);
detail_3_2 = int32(img_size_2(2)*0.01): int32(img_size_2(2)*0.13);
detail_4_1 = int32(img_size_2(1)*0.40): int32(img_size_2(1)*0.52);
detail_4_2 = int32(img_size_2(2)*0.69): int32(img_size_2(2)*0.81);

% draw the results
figure;
titles = {'\bfGray Image (1)', '\bfMarked Image (2)', ...
          '\bfColorized Image (3)', '\bfColorized Image using SW (4)', ...
          '\bfGray Image (5)', '\bfMarked Image (6)', ...
          '\bfColorized Image (7)', '\bfColorized Image using SW (8)'};

for idx = 1: 4
    subplot('Position', [0.25*(idx-1) 0.65 0.25 0.3]);
    imshow(img_out{idx});
    title(titles{idx}, 'fontsize', 11);
    
    if idx ~= 2
        subplot('Position', [0.025+0.25*(idx-1) 0.52 0.1 0.12]);
        imshow(img_out{idx}(detail_1_1, detail_1_2, :));
        subplot('Position', [0.125+0.25*(idx-1) 0.52 0.1 0.12]);
        imshow(img_out{idx}(detail_2_1, detail_2_2, :));
    end
end

for idx = 5: 8
    subplot('Position', [0.25*(idx-5) 0.15 0.25 0.3]);
    imshow(img_out{idx});
    title(titles{idx}, 'fontsize', 11);
    
    if idx ~= 6
        subplot('Position', [0.025+0.25*(idx-5) 0.02 0.1 0.12]);
        imshow(img_out{idx}(detail_3_1, detail_3_2, :));
        subplot('Position', [0.125+0.25*(idx-5) 0.02 0.1 0.12]);
        imshow(img_out{idx}(detail_4_1, detail_4_2, :));
    end
end

suptitle('\bf\fontsize{17}Demo 3 -- Image Colorization');

% save figure
fprintf('Saving figure.\n');
set(gcf, 'unit', 'centimeters', 'Position', [2 2 25 16]);
set(gcf, 'unit', 'centimeters', 'PaperPosition', [2 2 25 16]);  % adjust the size
print(gcf, '-r300', '-djpeg', 'demo_3.jpeg');  % save the image
fprintf('Finished.\n');
