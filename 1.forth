\ Define 16-bit fixed-point multiply operation (a*b >> 15)
: 16bit-multiply ( a b -- result )
  SWAP 15 RSHIFT ( a>>15 b )
  SWAP 15 LSHIFT ( a>>15 (b<<15) )
  * 15 RSHIFT ;  \ ((a>>15)*(b<<15))>>15

\ Allocate space for a 3D vector
CREATE vector 0 , 0 , 0 ,

\ Allocate space for a 3x3 rotation matrix
CREATE matrix 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 ,

: ele ( idx -- addr )  \ Fetch address of element at idx
  2* matrix + ;

: v-ele ( idx -- addr )  \ Fetch address of element at idx in vector
  2* vector + ;

: *v ( -- )
  \ Initialize sum to 0
  0 
  \ Loop through each row in matrix
  0 DO
    \ Loop through each column in matrix
    0 DO
      I 3 * J + ele @  ( get matrix[I][J] )
      J v-ele @  ( get vector[J] )
      16bit-multiply +  ( sum += matrix[I][J] * vector[J] )
    3 0 DO LOOP
    I v-ele !  \ Store sum into vector[I]
  3 0 DO LOOP ;

\ Initialize the vector and matrix
: init-data ( -- )
  2000 vector 2* ! 1000 vector 2* 2 + ! 3000 vector 2* 4 + !
  1000 matrix 2* ! 2000 matrix 2* 2 + ! 3000 matrix 2* 4 + !
  4000 matrix 2* 6 + ! 5000 matrix 2* 8 + ! 6000 matrix 2* 10 + !
  7000 matrix 2* 12 + ! 8000 matrix 2* 14 + ! 9000 matrix 2* 16 + ! ;

\ Example usage
init-data
*v

\ Fetch and display the rotated vector components
vector 2* @ . CR
vector 2* 2 + @ . CR
vector 2* 4 + @ . CR
