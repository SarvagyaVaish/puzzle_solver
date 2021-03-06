function [answer] = is_edge_straight(edge)
% PARAMS
fit_mask_width = 30;
error_threshold = 600;
global pieces;

% get the piece and find the angle the straight edge makes
piece = pieces{edge(1, 1)};
corner1 = piece.Corners(edge(1, 2), :);
corner2 = piece.Corners(mod(edge(1, 2), 4) + 1, :);
edge_length = round(sqrt(sum((corner1 - corner2) .^ 2)));
piece_size = size(piece.ImageBW);

pair = corner1 - corner2;
angle = atand(pair(1,1)/pair(1,2));
if pair(1,2) < 0
	angle = angle + 180;
end


% create the inner mask
mask = ones(fit_mask_width, edge_length)';
mask = boolean(bufferImage(mask));

mask_piece = puzzlePiece(mask);
mask_piece.ImageBW = mask;
mask_piece.ImageRGB = mask;
mask_piece = find_corner(mask_piece);
mask_size = size(mask_piece.ImageBW);
mask_piece = rotatePiece(mask_piece, angle);
mask_corner = mask_piece.Corners(1, :);


% create a comparison space and slap the piece in it
comparisonSpace = zeros(piece_size(1, 1)+ 2*mask_size(1, 1) + 5, piece_size(1, 2)+ 2*mask_size(1, 2) + 5);
insertionPoint = mask_size + 1;
comparisonSpace(insertionPoint(1, 2):insertionPoint(1, 2) + piece_size(1, 2) - 1, ...
	insertionPoint(1, 1):insertionPoint(1, 1) + piece_size(1, 1) - 1) = piece.ImageBW;

% create a mask comparison space and slap the mask on it
maskComparisonSpace = zeros(piece_size(1, 1)+ 2*mask_size(1, 1) + 5, piece_size(1, 2)+ 2*mask_size(1, 2) + 5);
insertionPoint = mask_size + corner1 + 1 - mask_corner;
maskComparisonSpace(insertionPoint(1, 2):insertionPoint(1, 2) + mask_size(1, 2) - 1, ...
	insertionPoint(1, 1):insertionPoint(1, 1) + mask_size(1, 1) - 1) = mask_piece.ImageBW;

error = sum(sum(not(comparisonSpace) & maskComparisonSpace));


% create the outer mask
mask = ones(fit_mask_width, edge_length)';
mask = boolean(bufferImage(mask));

mask_piece = puzzlePiece(mask);
mask_piece.ImageBW = mask;
mask_piece.ImageRGB = mask;
mask_piece = find_corner(mask_piece);
mask_size = size(mask_piece.ImageBW);
mask_piece = rotatePiece(mask_piece, angle);
mask_corner = mask_piece.Corners(3, :);


% create a comparison space and slap the piece in it
comparisonSpace = zeros(piece_size(1, 1)+ 2*mask_size(1, 1) + 5, piece_size(1, 2)+ 2*mask_size(1, 2) + 5);
insertionPoint = mask_size + 1;
comparisonSpace(insertionPoint(1, 2):insertionPoint(1, 2) + piece_size(1, 2) - 1, ...
	insertionPoint(1, 1):insertionPoint(1, 1) + piece_size(1, 1) - 1) = piece.ImageBW;

% create a mask comparison space and slap the mask on it
maskComparisonSpace = zeros(piece_size(1, 1)+ 2*mask_size(1, 1) + 5, piece_size(1, 2)+ 2*mask_size(1, 2) + 5);
insertionPoint = mask_size + corner2 + 1 - mask_corner;
maskComparisonSpace(insertionPoint(1, 2):insertionPoint(1, 2) + mask_size(1, 2) - 1, ...
	insertionPoint(1, 1):insertionPoint(1, 1) + mask_size(1, 1) - 1) = mask_piece.ImageBW;

notMaskComparisonSpace = not(maskComparisonSpace);
error = error + sum(sum(comparisonSpace & not(notMaskComparisonSpace)));

% if error < 600
% 	figure
% 	subplot(1, 3, 1)
% 	imshow(not(comparisonSpace) & maskComparisonSpace)
% 	subplot(1, 3, 2)
% 	imshow(comparisonSpace & not(notMaskComparisonSpace))
% 	subplot(1, 3, 3)
% 	imshow(comparisonSpace)
% end

if error < error_threshold
	answer = true;
else
	answer = false;
end

end
