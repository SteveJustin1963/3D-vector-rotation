 

# 3D-vector-rotation
3D vector rotation using 16-bit fixed-point arithmetic and a 3x3 matrix


### Theory of 3D Vector Rotation

3D vector rotation changes a vector's orientation in a three-dimensional space. This is typically done using rotation matrices that can rotate vectors while preserving their length.

In a 3D Cartesian coordinate system, you can rotate a vector around the x-axis, y-axis, or z-axis. The rotation matrices for these basic rotations are:

#### Rotation around the x-axis by angle \( \theta \):
![image](https://github.com/SteveJustin1963/3D-vector-rotation/assets/58069246/e0a99033-cdbe-4ed8-8f84-e578d44f42a5)


#### Rotation around the y-axis by angle \( \theta \):
![image](https://github.com/SteveJustin1963/3D-vector-rotation/assets/58069246/e4d07f38-0f10-4d46-b692-01f8f20681fc)


#### Rotation around the z-axis by angle \( \theta \):
![image](https://github.com/SteveJustin1963/3D-vector-rotation/assets/58069246/242701bd-e834-4329-b97c-ee8de4cc0924)


For more advanced rotations, you can combine these basic matrices or use other methods like Euler angles, quaternions, or axis-angle representations.

### 3D Vector Rotation Using 16-bit Fixed-Point Arithmetic

Fixed-point arithmetic is often suitable for scenarios where floating-point calculations are not feasible, like in embedded systems. In fixed-point arithmetic, real numbers are approximated using integers and are interpreted as fractions.

#### Fixed-Point Representation
In a 16-bit fixed-point format, 15 bits are used for the fractional part and one bit for the sign, effectively allowing you to represent numbers as X/2^15, where X is a 16-bit integer spanning from -32,768 to 32,767. This format limits the precision and range of representable numbers.

#### Fixed-Point Operations
Fixed-point arithmetic employs bit-shifting to maintain numerical integrity. For example, in 16-bit fixed-point multiplication, operands are usually shifted before and after the multiplication to ensure correct fixed-point representation.

#### Applying Fixed-Point Arithmetic to 3D Vector Rotation
When rotating a 3D vector using fixed-point arithmetic, all vectors and matrices must be represented in the fixed-point format. Given a 3D vector **v** and a rotation matrix **R**, the rotated vector **v'** is calculated as **v'= Rv**. In fixed-point arithmetic, each element **v'i** is:

![image](https://github.com/SteveJustin1963/3D-vector-rotation/assets/58069246/40ad599d-d6b0-48a9-bc7f-eb1853ce1f2f)


 



```
// 3D Vector Rotation using Fixed-point Arithmetic
// Uses 8.8 fixed point format for angles
// Variables:
// v = input vector array [x,y,z]
// m = rotation matrix array [9 elements]
// r = result vector array
// t = temporary calculations
// a = angle
// s = sin/cos lookup array

// Initialize sin/cos lookup table (0-90 degrees in 8.8 format)
:I [ 0 36 71 107 142 176 211 244 278 310 342 373 404 434 462
     490 517 543 568 592 615 637 658 678 696 714 731 746 760
     773 784 794 803 810 816 821 824 826 827 826 824 ] s! ;

// Get sine from lookup (angle in 8.8 format)
:S a! // angle input
   a #FF & // Get fraction
   a 8 } // Get degree
   s + ? // Lookup value
   a #100 >= ( // If angle > 90
     ~ // Negate if needed
   ) ;

// Get cosine (angle + 90 degrees)
:C a #100 + S ;

// Fixed point multiply
:M " * 8 } ; // a b -- result

// Initialize 3x3 rotation matrix for X rotation
:X a! // angle input
   a S a C    0 m! m! m! // Row 1
   a ~ C a S  0 m! m! m! // Row 2
   0 0 #100   m! m! m! ; // Row 3

// Initialize 3x3 rotation matrix for Y rotation
:Y a! // angle input
   a C 0 a ~ S m! m! m! // Row 1
   0 #100 0   m! m! m! // Row 2
   a S 0 a C  m! m! m! ; // Row 3

// Initialize 3x3 rotation matrix for Z rotation
:Z a! // angle input
   a C a ~ S 0 m! m! m! // Row 1
   a S a C 0  m! m! m! // Row 2
   0 0 #100   m! m! m! ; // Row 3

// Matrix multiply vector
:V [ 0 0 0 ] r! // Initialize result
   3 ( // For each row
     0 t! // Clear accumulator
     3 ( // For each column
       m /i 3 * /j + ? // Get matrix element
       v /j ? M // Multiply with vector element
       t + t! // Add to accumulator
     )
     t r /i ?! // Store result
   ) ;

// Test program
:T I // Initialize lookup tables
   // Test vector [100,0,0]
   [ #100 0 0 ] v!
   // Rotate 45 degrees around Z axis
   45 8 { Z // Convert 45 to 8.8 format
   V // Perform rotation
   // Display results
   `Rotated vector:` /N
   r 0 ? . r 1 ? . r 2 ? . ;

   ```


## MATLAB version of the 3D vector rotation code that mirrors our MINT2 implementation.

`3DVR.m`

This MATLAB implementation provides:

1. Core Functions:
- `rotate_floating`: Standard floating-point rotation
- `rotate_fixed`: Fixed-point rotation (8.8 format)
- `fixed_multiply`: Simulates 16-bit fixed-point multiplication
- `generate_sin_table`: Creates sine lookup table
- `get_sin_fixed`/`get_cos_fixed`: Fixed-point trigonometry

2. Test Functions:
- `test_3d_rotation`: Basic comparison test
- `test_fixed_point_accuracy`: Tests accuracy at various angles
- `plot_rotation_comparison`: Visual comparison

3. Features:
- Simulates MINT2's fixed-point arithmetic
- Includes lookup tables like MINT2 version
- Provides accuracy analysis
- Visual comparison capabilities

To use:
1. Save as `test_3d_rotation.m`
2. Run in MATLAB:

## result

```
>> test_3d_rotation
Original vector:
   100
     0
     0

Floating point rotation result:
   70.7107
   70.7107
         0

Fixed point rotation result:
   70.7031
   70.7031
         0

Difference:
    0.0076
    0.0076
         0
```

Result is correct! why?:

1. For a 45-degree rotation of vector [100, 0, 0]:
- Floating point gets us exactly cos(45°) × 100 ≈ 70.7107
- Fixed point gets us a very close 70.7031

2. The difference of about 0.0076 is expected and good because:
- We're using 8.8 fixed-point format (256 units = 1.0)
- This gives us precision to about 1/256 ≈ 0.00390625
- Our error is only about 2 units at that precision
- This represents an error of less than 0.01% of the original value

The small difference comes from:
- Rounding in the sine/cosine lookup tables
- Fixed-point multiplication rounding
- The limited precision of 8.8 format

This level of accuracy is good for fixed-point arithmetic and would be perfectly acceptable for most graphics and control applications.


  

