#CS 201 Performance Assignment

This assignment requires you to write a function, using inline assembly, that takes three arbitrary-length vectors of double-precision floating point numbers `a`, `b`, and `c`, and perform the following operation:
```
for(int i = 0; i < length; ++i) {
  a[i] += b[i] * c[i];
}
```

The code above will calculate the correct result, but it performs slowly. Yours will need to be faster. Fortunately, we have hardware support for this; modern processors have a set of vector extensions called AVX2 that will allow us to perform calculations on up to four doubles at a time. In fact, AVX2 adds support for exactly this purpose through the use of the new FMA3 [fused multiply-add](https://en.wikipedia.org/wiki/Multiply–accumulate_operation#Fused_multiply.E2.80.93add) instructions.

This repo provides skeleton code for creating random vectors and testing the performance of your code against a naïve scalar implementation like the one above.

###What to Submit

Your submission should be a single file with the title `submission.c`. This file should contain, at minimum, a function with the following signature:

`bool vector_fma(struct doubleVector * a, const struct doubleVector * b, const struct doubleVector * c)`

This function should work with the provided `main.c` and `Makefile`; there is no need to write or include your own. The function also should not print output to the screen or take input from the user.

The return value should indicate whether or not the computation was successful. The only case that I can think of off the top of my head that would cause this to fail is if the vectors had varying lengths.

###Grading Criteria

Assignments will be evaluated based on the following criteria:
* Your submission should use inline assembly and vector instructions
* Your submission should calculate the same result as the included scalar implementation for vector sets with arbitrary (strictly positive) lengths
* For a vector of length 10,000,000, your implementation should perform (at minimum) 20 times faster than the included scalar implementation.

If you'd like to try your code against the automated tests that they will be checked against, that code should be available as soon as it's finished here: https://github.com/RyanLB/CS-201-Public-Autograder-Tests

#Notes and Hints

To complete this assignment, you'll need to work on a processor that supports AVX2 instructions. I would recomment `linuxlab.cs.pdx.edu`, which is also where submissions will be tested.

Included in the distribution code is a file called `vectors.s`. This file contains a couple of assembly routines which are used to copy and compare vectors of doubles. Looking at these may be helpful, as they contain usage examples of most – if not all – of the vector instructions you need.

You may notice that the scalar implementation is also written in assembly, and uses the `vfmadd132sd` instruction. This is necessary because FMA instructions are [actually also more precise](https://en.wikipedia.org/wiki/Multiply–accumulate_operation) than a separate multiplication and addition, since we only need to round once. If you're attempting to debug your code in GDB or similar by checking its results against expressions like `a->data[0] + b->data[0] * c->data[0]`, you may notice minute differences in the smallest decimal digits; this is why.

###Vector Instructions

The two vector instructions described below are minimally sufficient to complete this assignment.

####`vmovupd`

`vmovupd`, or "Vector move unaligned packed doubles", is used to move multiple doubles at a time to or from floating-point registers. It is analogous to a regular `mov` instruction, and should therefore be pretty familiar. Examples of usage can be found in `vectors.c`.

The number of doubles is determined by the size of the source/destination registers. If we `vmovupd` from memory to a 128-bit register such as `xmm0`, we'll move two doubles; if we `vmovupd` to a 256-bit `ymm` register, we'll move four doubles.

####`vfmadd231pd`

`vfmadd231pd` performs a fused multiply-add operation on packed doubles. The `231` refers to the fact that in Intel syntax, this multiplies together the second and third operands and adds the product to the first.

Unfortunately, we're using AT&T syntax for our assembly, which means that our arguments are in the opposite order. Consider the following usage example:
```
vfmadd231pd %ymm0, %ymm1, %ymm2
```

This multiplies the packed doubles stored in `%ymm0` and `%ymm1`, and adds them to the packed doubles in `%ymm2`. Since in AT&T syntax, the destination comes last, the result is also stored in `%ymm2`.
