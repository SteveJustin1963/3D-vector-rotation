 

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
// Complete 3D Vector Rotation System
// Uses 8.8 fixed point format for calculations
// Variables:
// a = input angle
// t = temporary calculations
// v = input vector array
// s = sin/cos lookup table
// x,y,z = X rotation matrix rows
// p,q,r = Y rotation matrix rows
// u,v,w = Z rotation matrix rows

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

// Initialize 3x3 rotation matrix for X rotation - stored in x,y,z arrays
:X a! // angle input
   [a S a C 0] x! // Row 1 
   [a ~ C a S 0] y! // Row 2
   [0 0 #100] z! ; // Row 3

// Initialize 3x3 rotation matrix for Y rotation - stored in p,q,r arrays
:Y a! // angle input
   [a C 0 a ~ S] p! // Row 1
   [0 #100 0] q! // Row 2
   [a S 0 a C] r! ; // Row 3

// Initialize 3x3 rotation matrix for Z rotation - stored in u,v,w arrays
:Z a! // angle input
   [a C a ~ S 0] u! // Row 1
   [a S a C 0] v! // Row 2
   [0 0 #100] w! ; // Row 3

// Generic matrix multiply vector (m1,m2,m3 are the matrix rows)
:V [ 0 0 0 ] t! // Initialize result
   3 ( // For each row
     0 n! // Clear accumulator
     3 ( // For each column
       /i /j ?M @ // Get matrix element from indicated row
       v /j ? M // Multiply with vector element
       n + n! // Add to accumulator
     )
     n t /i ?! // Store result
   ) ;

// Matrix multiply using X rotation
:VX x y z V ;

// Matrix multiply using Y rotation
:VY p q r V ;

// Matrix multiply using Z rotation
:VZ u v w V ;

// Test program
:T I // Initialize lookup tables
   // Test vector [100,0,0]
   [ #100 0 0 ] v!
   
   // Test X rotation 45 degrees
   45 8 { X // Convert 45 to 8.8 format and create matrix
   VX // Perform rotation
   `X rotation:` /N
   t 0 ? . t 1 ? . t 2 ? . /N
   
   // Test Y rotation 45 degrees
   45 8 { Y // Create Y matrix
   VY // Perform rotation
   `Y rotation:` /N
   t 0 ? . t 1 ? . t 2 ? . /N
   
   // Test Z rotation 45 degrees
   45 8 { Z // Create Z matrix
   VZ // Perform rotation
   `Z rotation:` /N
   t 0 ? . t 1 ? . t 2 ? . ;

```

1. Separate storage for each rotation matrix (X,Y,Z)
2. Single array store per matrix row
3. Better variable organization
4. Clearer matrix multiply logic
5. Comprehensive test program

To use:
1. Run :I to initialize lookup tables
2. Create a vector with [ x y z ] v!
3. Use :X, :Y, or :Z to create rotation matrix
4. Use :VX, :VY, or :VZ to apply rotation
5. Result is in t array

Example:
```mint
:R I                    // Initialize
   [ #100 0 0 ] v!     // Set vector
   45 8 { Z            // 45 degree Z rotation
   VZ                  // Rotate
   t 0 ? . t 1 ? . t 2 ? . ; // Show result
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


  

