function kernels = get_kernels(radius, type)
% Get 8 kernels of different side windows
% L, R, U, D, NW, NE, SW, SE
r = radius;
len = 2*r+1;
% kernels = zeros(len, len, 8, 'double');

% Box Filter
if strcmp(type, 'box')
    k = ones(len, 1);  % separable kernel 
    k_L = k;
    k_L(r+2: end) = 0;
    k_R = flipud(k_L);
    kernels = cat(3, k   * k_L', k   * k_R', k_L * k'  , k_R * k'  , ...
                     k_L * k_L', k_L * k_R', k_R * k_L', k_R * k_R');

% Mean Filter
elseif strcmp(type, 'mean')
    k = ones(len, 1) / len;  % separable kernel 
    k_L = k;
    k_L(r+2: end) = 0;
    k_L = k_L / sum(k_L);  % half kernel
    k_R = flipud(k_L);
    kernels = cat(3, k   * k_L', k   * k_R', k_L * k'  , k_R * k'  , ...
                     k_L * k_L', k_L * k_R', k_R * k_L', k_R * k_R');

% Median Filter (give valid elem 1, and not valid elem NaN)
elseif strcmp(type, 'median')
    k = ones(len, 1);  % separable kernel, all elem set to 1
    k_L = k;
    k_L(r+2: end) = NaN;  % half kernel
    k_R = flipud(k_L);
    kernels = cat(3, k   * k_L', k   * k_R', k_L * k'  , k_R * k'  , ...
                     k_L * k_L', k_L * k_R', k_R * k_L', k_R * k_R');
    
% Guassian Filter
elseif strcmp(type, 'gaussian')
    gaus_kernel = fspecial('gaussian', [len len], 1);  % default sigma 1
    gaus_kernel = gaus_kernel * gaus_kernel';
    
    k_half = gaus_kernel(:, 1:r+1);
    k_L = [k_half zeros(len, r)] ./ sum(k_half(:));
    k_R = fliplr(k_L);
    k_U = k_L';
    k_D = flipud(k_U);
    k_quad = gaus_kernel(1:r+1, 1:r+1);
    k_NW = [k_quad zeros(r+1, r); zeros(r, len)] ./ sum(k_quad(:));
    k_NE = fliplr(k_NW);
    k_SW = flipud(k_NW);
    k_SE = flipud(k_NE);
    kernels = cat(3, k_L, k_R, k_U, k_D, k_NW, k_NE, k_SW, k_SE);

else
	ME = MException('myComponent:inputError', 'Filter type error. (box, mean, median, gaussian)');
	throw(ME);
end

end
