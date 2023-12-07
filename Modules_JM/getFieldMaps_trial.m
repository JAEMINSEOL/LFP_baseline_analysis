% Linearization

pos_trial = pos & trial(:,trial_iter);
spks_trial = spks & trial_spk(:,trial_iter);

%% Define stem part
pos_stem = logical([]); spks_stem = logical([]);
pos_stem = pos_trial & inpolygon(x, y, stem_boundary(1,:), stem_boundary(2,:));
spks_stem = spks_trial & inpolygon(x_spk, y_spk, stem_boundary(1,:), stem_boundary(2,:));

%% binning stem part.
bin_size = 10;

bin_position = [];
bin_spikes = [];
index = 1;

for iterA = max(stem_boundary(2,:)) : bin_size * (-1) : diverging_point + bin_size
    temp_pos = y <= iterA & y > iterA - bin_size;
    temp_spk = y_spk <= iterA & y_spk > iterA - bin_size;
    
    bin_position(index, 1) = sum(temp_pos & pos_stem);
    bin_spikes(index, 1) = sum(temp_spk & spks_stem);
    
    index = index + 1;
end

% binning corner area & arm part
divide_number = 5;
corner_angle = pi/2 / divide_number;
temp_boundary = [];

% Left response side
if trial_side(trial_iter) == 1
    
    % binning corner area (equal angle)
    corner_origin = [min(corner_boundary_left(1,:)), max(corner_boundary_left(2,:))];
    temp_boundary(1:2,1) = corner_origin;
    corner_radius = max(diff(corner_boundary_left(1,:)));
    
    for iter = 1:divide_number
        
        [temp_boundary(1,2), temp_boundary(2,2)] = pol2cart((iter - 1) * corner_angle, corner_radius);
        [temp_boundary(1,3), temp_boundary(2,3)] = pol2cart(iter * corner_angle, corner_radius);
        
        temp_boundary(1,2:3) = corner_origin(1,1) + temp_boundary(1,2:3);
        temp_boundary(2,2:3) = corner_origin(1,2) - temp_boundary(2,2:3);
        
        temp_pos = inpolygon(x, y, temp_boundary(1,:), temp_boundary(2,:));
        temp_spk = inpolygon(x_spk, y_spk, temp_boundary(1,:), temp_boundary(2,:));
        
        bin_position(index, 1) = sum(temp_pos & pos_trial);
        bin_spikes(index, 1) = sum(temp_spk & spks_trial);
        
        index = index + 1;
    end
    
    % binning arm part.
    for iterA = min(corner_boundary_left(1,:)) : bin_size * (-1) : min(xEdge)
        temp_pos = x <= iterA & x > iterA - bin_size;
        temp_spk = x_spk <= iterA & x_spk > iterA - bin_size;
        
        bin_position(index, 1) = sum(temp_pos & pos_trial & ~pos_stem);
        bin_spikes(index, 1) = sum(temp_spk & spks_trial & ~spks_stem);
        
        temp_pos = temp_pos & logical(sum(pos_trial, 2)) & ~logical(sum(pos_stem, 2));
        
        index = index + 1;
    end
        
    % Right response side
elseif trial_side(trial_iter) == 2
    
    % binning corner area (equal angle)
    corner_origin = [max(corner_boundary_right(1,:)), max(corner_boundary_right(2,:))];
    temp_boundary(1:2,1) = corner_origin;
    corner_radius = max(diff(corner_boundary_right(1,:)));
    
    for iter = 1:divide_number
        
        [temp_boundary(1,2), temp_boundary(2,2)] = pol2cart(pi - (iter - 1) * corner_angle, corner_radius);
        [temp_boundary(1,3), temp_boundary(2,3)] = pol2cart(pi - iter * corner_angle, corner_radius);
        
        temp_boundary(1,2:3) = corner_origin(1,1) + temp_boundary(1,2:3);
        temp_boundary(2,2:3) = corner_origin(1,2) - temp_boundary(2,2:3);
        
        temp_pos = inpolygon(x, y, temp_boundary(1,:), temp_boundary(2,:));
        temp_spk = inpolygon(x_spk, y_spk, temp_boundary(1,:), temp_boundary(2,:));
        
        bin_position(index, 1) = sum(temp_pos & pos_trial);
        bin_spikes(index, 1) = sum(temp_spk & spks_trial);
        
        index = index + 1;
    end
    
    % binning arm part.
    for iterA = max(corner_boundary_right(1,:)) : bin_size : max(xEdge)
        temp_pos = x >= iterA & x < iterA + bin_size;
        temp_spk = x_spk >= iterA & x_spk < iterA + bin_size;
        
        
        bin_position(index, 1) = sum(temp_pos & pos_trial & ~pos_stem);
        bin_spikes(index, 1) = sum(temp_spk & spks_trial & ~spks_stem);
        
        temp_pos = temp_pos & logical(sum(pos_trial, 2)) & ~logical(sum(pos_stem, 2));
        
        index = index + 1;
    end
    
end % if trial_side

arm_end_index = index - 1;


%% make maps

% clear temp_pos temp_spk;
temp_pos = []; temp_spk = [];
for iterA = 1 : arm_end_index
    temp_pos(end + 1 : end + bin_position(iterA, 1), 3) = iterA - 1;
    temp_spk(end + 1 : end + bin_spikes(iterA, 1), 3) = iterA - 1;
end
temp_pos(:, 1:2) = 0;
temp_spk(:, 1:2) = 0;

% [~, ~, rawMap1D_trial(:,trial_iter), ~] = fixFiringRateMap_2b4(temp_spk, temp_pos, arm_end_index, 1, 1, videoSamplingRate, fixRadius);
[~, ~, rawMap1D_trial{trial_iter}, ~] = fixFiringRateMap_2b4(temp_spk, temp_pos, arm_end_index, 1, 1, videoSamplingRate, fixRadius);

