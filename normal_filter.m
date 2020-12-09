function result = normal_filter(image, type, radius, iteration)
% normal filter

% image:     input uint8 format image
% type:      filter type (mean, median, gaussian)
% radius:    radius of the side window
% iteration: process times
% result:    output uint8 format image

image = single(image);
result = image;
r = radius;            % filter radius
len = 2*r+1;           % filter length
chs = size(image, 3);  % channels

m = size(image, 1) + 2*r;
n = size(image, 2) + 2*r;

% Create waitbar.
h = waitbar(0, 'Processing...');
set(h, 'Name', 'Normal Filtering');

for ch = 1: chs
    U = padarray(image(:, :, ch), [r r], 'replicate');
    U_out = U;
    for i = 1: iteration
        if strcmp(type, 'median')
            U_out = medfilt2(U, [len len], 'symmetric');
%             for idx1 = 1: m-len+1
%                 for idx2 = 1: n-len+1
%                     roi = U(idx1:(idx1+len-1), idx2:(idx2+len-1) );  % valid area
%                     med = median(roi(:));  % count the median value
%                     U_out(idx1+r, idx2+r) = med;
%                 end
%             end
        elseif strcmp(type, 'box')
            k = fspecial('average', [len len]) .* len^2;
            U_out = conv2(U, k, 'same');
        elseif strcmp(type, 'mean')
            k = fspecial('average', [len len]);
            U_out = conv2(U, k, 'same');
        elseif strcmp(type, 'gaussian')
            k = fspecial('gaussian', [len len], 1);  % default sigma 1
            U_out = conv2(U, k, 'same');
        end
        waitbar(((ch-1)*iteration + i) / chs / iteration);
        
    end
    result(:, :, ch) = U_out(r+1:end-r, r+1:end-r);
end

result = uint8(result);
close(h);
end

