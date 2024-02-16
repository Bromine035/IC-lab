# Online Test - Triangle

- Topic: Use Design Ware IP to perform fixed point division  
- TA: 黃熙皓  

## Overview

&nbsp;&nbsp;&nbsp;&nbsp;The object of this design is to calculate the 3 *cosine* values of the 3 angles of a triangle, and then judge it is a right, acute or obtuse triangle, according to the 3 side lengths provided.  
&nbsp;&nbsp;&nbsp;&nbsp;When ```in_valid``` is high, the 3 side lengths will be inputed from ```in_length``` for 3 cycles, and after our calculation, we have to pull high ```out_valid``` 
and output the 3 *cosine* values through ```out_cos``` and triangle type through ```out_tri``` for 3 cycles.  

## The following files are contributed:  
```
./TRIANGLE.v
```
