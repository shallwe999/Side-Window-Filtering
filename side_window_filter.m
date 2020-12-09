function result = side_window_filter(image, type, radius, iteration)
% Related paper: Side Window Filtering, H.Yin, Y.Gong, G.Qiu. CVPR2019

% image:     input uint8 format image
% type:      filter type (box, mean, median, gaussian)
% radius:    radius of the side window
% iteration: process times
% result:    output uint8 format image

image = single(image);
result = image;
r = radius;            % filter radius
len = 2*r+1;           % filter length
chs = size(image, 3);  % channels
kernels = single(get_kernels(r, type));

m = size(image, 1) + 2*r;
n = size(image, 2) + 2*r;
total = m * n;
[row, col] = ndgrid(1:m, 1:n); 
offset = row + m*(col-1) - total;
d = zeros(m, n, 8, 'single'); 

% Create waitbar.
h = waitbar(0, 'Processing...');
set(h, 'Name', 'Side Window Filtering');

for ch = 1: chs
    U = padarray(image(:, :, ch), [r r], 'replicate');
    for i = 1: iteration
        % count all projection distances
        if strcmp(type, 'median')
            for k_idx = 1: 8
                for idx1 = 1: m-len+1
                    for idx2 = 1: n-len+1
                        roi = U(idx1:(idx1+len-1), idx2:(idx2+len-1) );  % valid area
                        roi = roi .* kernels(:, :, k_idx);
                        med = median(roi(:), 'omitnan');  % count the median value
                        d(idx1+r, idx2+r, k_idx) = med;
                    end
                end
                d(:, :, k_idx) = d(:, :, k_idx) - U;
                waitbar(((ch-1)*iteration*8 + (i-1)*8 + k_idx) / chs / iteration / 8);
            end            
        else
            for k_idx = 1: 8
                d(:, :, k_idx) = conv2(U, kernels(:, :, k_idx), 'same') - U;
                waitbar(((ch-1)*iteration*8 + (i-1)*8 + k_idx) / chs / iteration / 8);
            end
        end
        
        % find the minimal signed distance
        tmp = abs(d); 
        [~, ind] = min(tmp, [], 3); 
        index = offset + total*ind;
        dm = d(index);  % signed minimal distance
        U = U + dm;  % update
    end
    result(:, :, ch) = U(r+1:end-r, r+1:end-r);
end

result = uint8(result);
close(h);
end

