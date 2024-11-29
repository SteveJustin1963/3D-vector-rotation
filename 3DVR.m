% 3D Vector Rotation Test Suite
% Compares floating-point vs fixed-point implementations

function test_3d_rotation()
    % Test parameters
    vector = [100; 0; 0];    % Test vector
    angle_deg = 45;          % Test angle in degrees
    
    % Test both implementations
    result_float = rotate_floating(vector, angle_deg);
    result_fixed = rotate_fixed(vector, angle_deg);
    
    % Display results
    disp('Original vector:');
    disp(vector);
    disp('Floating point rotation result:');
    disp(result_float);
    disp('Fixed point rotation result:');
    disp(result_fixed);
    disp('Difference:');
    disp(result_float - result_fixed);
end

function result = rotate_floating(vector, angle_deg)
    % Standard floating-point implementation
    angle_rad = deg2rad(angle_deg);
    Rz = [cos(angle_rad) -sin(angle_rad) 0;
          sin(angle_rad)  cos(angle_rad) 0;
          0              0              1];
    result = Rz * vector;
end

function result = rotate_fixed(vector, angle_deg)
    % Fixed-point implementation (8.8 format)
    % Initialize lookup tables
    sin_table = generate_sin_table();
    
    % Convert angle to 8.8 fixed point
    angle_fixed = round(angle_deg * 256 / 360 * 90);  % Scale to 90-degree range
    
    % Get sin/cos values from lookup
    sin_val = get_sin_fixed(angle_fixed, sin_table);
    cos_val = get_cos_fixed(angle_fixed, sin_table);
    
    % Create rotation matrix in fixed point
    Rz = [cos_val -sin_val 0;
          sin_val  cos_val 0;
          0        0       256];  % 1.0 in 8.8 format
    
    % Perform matrix multiplication in fixed point
    result = zeros(3,1);
    for i = 1:3
        sum = 0;
        for j = 1:3
            sum = sum + fixed_multiply(Rz(i,j), vector(j));
        end
        result(i) = sum;
    end
    
    % Convert back to floating point
    result = result / 256;  % Scale back from 8.8 format
end

function result = fixed_multiply(a, b)
    % Simulate 16-bit fixed-point multiplication
    result = floor((a * b) / 256);
    % Simulate 16-bit overflow
    result = mod(result + 32768, 65536) - 32768;
end

function sin_table = generate_sin_table()
    % Generate sine lookup table (0-90 degrees in 8.8 format)
    sin_table = zeros(91, 1);
    for i = 0:90
        sin_table(i+1) = round(sin(deg2rad(i)) * 256);
    end
end

function val = get_sin_fixed(angle_fixed, sin_table)
    % Get sine value from lookup table
    angle_deg = mod(angle_fixed * 360 / (256 * 90), 360);
    if angle_deg <= 90
        val = sin_table(floor(angle_deg) + 1);
    elseif angle_deg <= 180
        val = sin_table(91 - floor(angle_deg - 90));
    elseif angle_deg <= 270
        val = -sin_table(floor(angle_deg - 180) + 1);
    else
        val = -sin_table(91 - floor(angle_deg - 270));
    end
end

function val = get_cos_fixed(angle_fixed, sin_table)
    % Get cosine by shifting sine lookup by 90 degrees
    val = get_sin_fixed(angle_fixed + 64, sin_table);  % 64 = 90° in 8.8 format
end

% Extra test functions to validate implementation

function test_fixed_point_accuracy()
    % Test fixed-point accuracy at various angles
    angles = 0:15:360;
    max_error = 0;
    
    for angle = angles
        vec = [100; 0; 0];
        res_float = rotate_floating(vec, angle);
        res_fixed = rotate_fixed(vec, angle);
        error = max(abs(res_float - res_fixed));
        max_error = max(max_error, error);
        
        fprintf('Angle: %d degrees, Max Error: %.4f\n', angle, error);
    end
    
    fprintf('\nOverall maximum error: %.4f\n', max_error);
end

function plot_rotation_comparison()
    % Visual comparison of floating vs fixed point
    angles = 0:5:360;
    results_float = zeros(length(angles), 2);
    results_fixed = zeros(length(angles), 2);
    vec = [100; 0; 0];
    
    for i = 1:length(angles)
        res_float = rotate_floating(vec, angles(i));
        res_fixed = rotate_fixed(vec, angles(i));
        results_float(i,:) = res_float(1:2)';
        results_fixed(i,:) = res_fixed(1:2)';
    end
    
    figure;
    plot(results_float(:,1), results_float(:,2), 'b-', 'LineWidth', 2);
    hold on;
    plot(results_fixed(:,1), results_fixed(:,2), 'r--', 'LineWidth', 1);
    legend('Floating Point', 'Fixed Point');
    title('Rotation Comparison: Floating vs Fixed Point');
    xlabel('X');
    ylabel('Y');
    grid on;
    axis equal;
end
