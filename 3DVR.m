% 3D Vector Rotation Test Suite - Fixed Version
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
    SCALE = 256;  % 8.8 fixed point scale factor
    
    % Scale input vector to fixed point
    vector_fixed = round(vector * SCALE);
    
    % Convert angle to fixed point (90 degrees = 64 in our format)
    angle_fixed = round(angle_deg * 64 / 90);
    
    % Get sin/cos values
    sin_val = get_sin_fixed(angle_fixed);
    cos_val = get_cos_fixed(angle_fixed);
    
    % Create rotation matrix in fixed point
    Rz = [cos_val, -sin_val, 0;
          sin_val,  cos_val, 0;
          0,        0,       SCALE];
    
    % Perform matrix multiplication maintaining fixed point
    result = zeros(3,1);
    for i = 1:3
        sum = 0;
        for j = 1:3
            prod = fixed_multiply(Rz(i,j), vector_fixed(j));
            sum = sum + prod;
        end
        % Convert back to floating point
        result(i) = sum / SCALE;
    end
end

function result = fixed_multiply(a, b)
    % Simulate 16-bit fixed-point multiplication with proper scaling
    SCALE = 256;
    result = floor((a * b) / SCALE);
    % Simulate 16-bit overflow
    result = mod(result + 32768, 65536) - 32768;
end

function val = get_sin_fixed(angle)
    % Get sine value in fixed point format (8.8)
    % Input angle is in 64 units per 90 degrees
    SCALE = 256;
    
    % Normalize angle to 0-255 range (0-360 degrees)
    angle = mod(angle, 256);
    
    % Convert to radians for MATLAB's sin function
    angle_rad = (angle * 2 * pi) / 256;
    
    % Convert to fixed point
    val = round(sin(angle_rad) * SCALE);
end

function val = get_cos_fixed(angle)
    % Get cosine by shifting sine lookup by 64 units (90 degrees)
    val = get_sin_fixed(angle + 64);
end

% Test plotting function
function plot_rotation_test()
    % Create test vector
    vector = [100; 0; 0];
    
    % Test multiple angles
    angles = 0:15:360;
    float_points = zeros(length(angles), 2);
    fixed_points = zeros(length(angles), 2);
    
    for i = 1:length(angles)
        res_float = rotate_floating(vector, angles(i));
        res_fixed = rotate_fixed(vector, angles(i));
        float_points(i,:) = res_float(1:2)';
        fixed_points(i,:) = res_fixed(1:2)';
    end
    
    % Plot results
    figure;
    plot(float_points(:,1), float_points(:,2), 'b-', 'LineWidth', 2);
    hold on;
    plot(fixed_points(:,1), fixed_points(:,2), 'r--', 'LineWidth', 1);
    plot([0 vector(1)], [0 vector(2)], 'k-', 'LineWidth', 2);
    legend('Floating Point', 'Fixed Point', 'Original Vector');
    title('Vector Rotation Comparison');
    xlabel('X');
    ylabel('Y');
    grid on;
    axis equal;
end
