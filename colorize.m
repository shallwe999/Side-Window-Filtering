function img_colorized = colorize(img_color, img_ntsc, radius, use_side_window)

m = size(img_ntsc, 1);
n = size(img_ntsc, 2);
img_size = m * n;

img_colorized(:,:,1) = img_ntsc(:,:,1);

idx_lbl = find(img_color);  % find index of draw color area

r = radius;  % radius of window
if radius <= 0 || (radius == 1 && use_side_window)
    ME = MException('myComponent:inputError', 'Window radius error.');
	throw(ME);
end

% Create waitbar.
h = waitbar(0, 'Processing...');
set(h, 'Name', 'Colorization');

len = 0;
col_inds = zeros(img_size * (2*r+1)^2, 1);
row_inds = zeros(img_size * (2*r+1)^2, 1);
vals = zeros(img_size * (2*r+1)^2, 1);
gvals = zeros(1, (2*r+1)^2);

if use_side_window
    U = padarray(img_ntsc(:, :, 1), [r r], 'replicate') * 255;
    
    kernels = double(get_kernels(r, 'mean'));
    d = zeros(m+2*r, n+2*r, 8);
    
    for iter = 1: 10  % 10 iterations
        for k_idx = 1: 8
            d(:, :, k_idx) = conv2(U, kernels(:, :, k_idx), 'same') - U;
        end
        tmp = abs(d); 
        [~, kernel_inds] = min(tmp, [], 3);
        [row, col] = ndgrid(1:m+2*r, 1:n+2*r); 
        offset = row + (m+2*r)*(col-1) - (m+2*r)*(n+2*r);
        index = offset + (m+2*r)*(n+2*r)*kernel_inds;
        dm = d(index);  % signed minimal distance
        U = U + dm;  % update
    end
    
    % find the minimal signed distance
    tmp = abs(d); 
    [~, kernel_inds] = max(tmp, [], 3);  % why does 'max' works ?
    
    % simplified for searching
    kernels = (kernels~=0);
    kernel_inds = uint8(kernel_inds);
end

for j = 1: n
    for i = 1: m
        if ~img_color(i, j)
            tlen = 0;
            
            if use_side_window
                % side window selection
                kernel = kernels(:, :, kernel_inds(i+r, j+r));
                kernel(r+1, r+1) = 0;  % drop the center (ii~=i || jj~=j)
                for ii = max(1, i-r): min(i+r, m)
                    for jj = max(1, j-r): min(j+r, n)
                        if kernel(ii-i+r+1, jj-j+r+1)~=0
                            len = len+1;
                            tlen = tlen+1;
                            row_inds(len) = (j-1)*m + i;
                            col_inds(len) = (jj-1)*m + ii;
                            gvals(tlen) = img_ntsc(ii, jj, 1);
                        end
                    end
                end
            else
                % not use side window, check the whole window
                for ii = max(1, i-r): min(i+r, m)
                    for jj = max(1, j-r): min(j+r, n)
                        if ii~=i || jj~=j  % drop the center
                            len = len+1;
                            tlen = tlen+1;
                            row_inds(len) = (j-1)*m + i;
                            col_inds(len) = (jj-1)*m + ii;
                            gvals(tlen) = img_ntsc(ii, jj, 1);
                        end
                    end
                end
            end
            
            t_val = img_ntsc(i, j, 1);
            gvals(tlen+1) = t_val;
            c_var = mean((gvals(1:tlen+1)-mean(gvals(1:tlen+1))).^2);
            csig = c_var*2;  % 0.6
            mgv = min((gvals(1:tlen)-t_val).^2);
        
            if csig < -mgv/log(0.01)
                csig = -mgv/log(0.01);
            end
            if csig < 0.000002
                csig = 0.000002;
            end
            
            gvals(1:tlen) = exp(-(gvals(1:tlen)-t_val).^2/csig);
            gvals(1:tlen) = gvals(1:tlen) / sum(gvals(1:tlen));
            vals(len-tlen+1:len) = -gvals(1:tlen);
                        
        end

        len = len+1;
        row_inds(len) = (j-1)*m + i;
        col_inds(len) = (j-1)*m + i;
        vals(len) = 1;
        
    end
    waitbar(0.75 * j/n);
end

col_inds = col_inds(1:len);
row_inds = row_inds(1:len);
vals = vals(1:len);

A = sparse(row_inds, col_inds, vals, img_size, img_size);
b = zeros(size(A,1), 1);

for ch = 2: 3
    img_temp = img_ntsc(:,:,ch);
    b(idx_lbl) = img_temp(idx_lbl);
    new_vals = A\b;
    img_colorized(:,:,ch) = reshape(new_vals,m,n,1);
    waitbar(0.75 + 0.125*(ch-1));
end

close(h);
end

