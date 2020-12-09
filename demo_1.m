clear;
fprintf('   ******   Side Window Filtering   ******\n');
fprintf('Demo 1 -- Image Smoothing and Edge Preserving\n');

img_out = cell(1, 5);
str_out = cell(1, 5);

% image preprocess
img = imread('test_images/lena.jpg');
img_size = size(img, 1:2);
img_out{1} = img;

%% Test 1 - Median Filter
img_out{2} = normal_filter(img, 'median', 3, 5);
str_out{2} = sprintf('SSIM: %.3f', ssim(img_out{2}, img));
fprintf('Process 1/4 finished.\n');
img_out{3} = side_window_filter(img, 'median', 3, 5);
str_out{3} = sprintf('SSIM: %.3f', ssim(img_out{3}, img));
fprintf('Process 2/4 finished.\n');

%% Test 2 - Mean Filter
img_out{4} = normal_filter(img, 'mean', 3, 5);
str_out{4} = sprintf('SSIM: %.3f', ssim(img_out{4}, img));
fprintf('Process 3/4 finished.\n');
img_out{5} = side_window_filter(img, 'mean', 3, 5);
str_out{5} = sprintf('SSIM: %.3f', ssim(img_out{5}, img));
fprintf('Process 4/4 finished.\n');

%% Show and save results
% count detail area
detail_1_1 = int32(img_size(1)*0.44): int32(img_size(1)*0.56);
detail_1_2 = int32(img_size(2)*0.38): int32(img_size(2)*0.50);
detail_2_1 = int32(img_size(1)*0.70): int32(img_size(1)*0.82);
detail_2_2 = int32(img_size(2)*0.57): int32(img_size(2)*0.69);

% draw the results
figure;
titles = {'\bfOriginal Image (1)', ...
          '\bfMedian Filter (2)', '\bfSide Window Median Filter (3)', ...
          '\bfMean Filter (4)', '\bfSide Window Mean Filter (5)'};

for idx = 1: 5
    subplot('Position', [0.2*(idx-1) 0.4 0.2 0.46]);
    imshow(img_out{idx});
    title(titles{idx}, 'fontsize', 12);
    if idx ~= 1
        text(15, 30, str_out{idx}, 'FontWeight', 'bold', 'Color', [0.99 0.99 0.99]);
    end
    subplot('Position', [0.01+0.2*(idx-1) 0.16 0.09 0.18]);
    imshow(img_out{idx}(detail_1_1, detail_1_2, :));
    subplot('Position', [0.10+0.2*(idx-1) 0.16 0.09 0.18]);
    imshow(img_out{idx}(detail_2_1, detail_2_2, :));
end

suptitle('\bf\fontsize{17}Demo 1 -- Image Smoothing and Edge Preserving');

% save figure
fprintf('Saving figure.\n');
set(gcf, 'unit', 'centimeters', 'Position', [2 2 30 12]);
set(gcf, 'unit', 'centimeters', 'PaperPosition', [2 2 30 12]);  % adjust the size
print(gcf, '-r300', '-djpeg', 'demo_1.jpeg');  % save the image
fprintf('Finished.\n');
