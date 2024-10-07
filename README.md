# Linear Reduction
*Ari Feiglin and Noam Kaplinski under the guidance of Dr. Yoni Zohar*

## Introduction

This project implements a method we devised for interpreting and executing code, as well as comparing this new
method with an existing algorithm.
We intend to show that our algorithm works, by providing both a formal proof of a fragment of it as well as
running example programs using it.

We use our algorithm to implement an interpreter for a toy language in OCaml, and we provide two alternative
methods for interpreting this language:
1. a fully functional interpreter implemented in OCaml using [Menhir](https://gallium.inria.fr/~fpottier/menhir/)
2. a program which transforms code known ahead of time into OCaml which can then be interpreted by OCaml itself.

## Downloading and Building

### Downloading the Source

Ensure you have git installed and run (in the desired directory)
```sh
git clone https://github.com/ari-feiglin/linear-reduction
```
This should clone all the source into a directory called `linear-reduction`.
Now `cd` into this directory:
```sh
cd linear-reduction
```
All subsequent commands are done relative to this directory.

Now to continue building, you must compile the source for our implementations of our and the clasical
algorithms.

### Linear Reduction Implementation

Navigate to the source for the implementation of linear reduction:
```sh
cd Source
```
Set up the opam environment
```sh
eval $(opam env)
```
Run make
```sh
make
```
This will compile the source into an executable `llang` under the `linear-reduction` directory.
Note that a `make clean` command is provided as well.

### Classical Implementation

Navigate to the source for the classical implementation:
```sh
cd Classical-Source
```
Run make
```sh
make
```
This will compile the source into an executable `llang-classical` under the `linear-reduction` directory.
Note that a `make clean` command is provided as well.

## Running

Demo files are provided in the `Demos/` directory.

### Linear Reduction Implementation

To run our implementation of our algorithm, simply run `./llang <file path> [y]`.
This will execute the file specified by the path `<file path>`.
Debugging information is printed unless `[y]` is specified.

### Classical Implementation

To run our implementation of the classical algorithm, simply run `./llang-classical <file path>`.
This will execute the file specified by the path `<file path>`.

## Comparisons

Python scripts for comparing runtimes of our and the classical algorithms are provided in the `Comparisons/` directory.
Commands in this section are relative to the `Comparisons/` directory.

### Finding the Mean Runtime

To find the mean runtime of each algorithm on a set program specified by `<file path>`, run
```sh
python3 comparer.py <file path>
```
This will run the program 300 times with each interpreter, and present the results.
It will print the mean runtimes (in seconds) as well as a bar graph representing the total time each interpreter ran.

For example,
```sh
python3 comparer.py ../Demos/currying.ml
```
will produce
![](./Docs/Images/currying.png)

Our algorithm takes on average 0.0040886 seconds to execute, while the classical algorithm takes 0.00369256 seconds.

### Fibonacci

Another demo program provided is `Demos/fibonacci.ml`, which uses the standard recursive formula to compute `fibonacci(n)` (`n` is hard-coded in the file).
We can graph the time it takes each algorithm to compute `fibonacci(n)` as a function of `n`, by using the `fib-compare.py` program.
Simply run
```sh
python3 fib-compare.py
```
and it will produce a graph of the runtimes.
![](./Docs/Images/fib.png)
Using exponential regression, we can estimate that the runtime for both algorithms are $`a\cdot b^n`$ where
```math
\text{Our Algorithm: } a=0.000138585, b=1.64685, \qquad \text{Classical Algorithm: } a=0.00000362553, b=1.5809
```

### Arithmetical Expressions

We provide a script `Demos/create-expression.py` to create complex arithmetical expressions.
We can then time the time it takes for each interpreter to parse and compute the expression.
Each expression is parameterized by a length and depth, where the length is the number of parenthesized subexpressions in the expression, and depth is the depth of parentheses.
To create an expression with a specified length and depth, run
```sh
python3 create-expression.py <length> <depth>
```
And this will put the expression in a file called `expression.txt`.

We also provide a script in `Comparisons/expr-compare.py` to compare the runtimes of each interpreter.
Simply run
```sh
python3 expr-compare.py
```
and it will produce a plot of the times:
![](./Docs/Images/expr.png)

### Conclusions

As we can see, in each of the benchmark tests, the classical algorithm is quicker than ours.
This is not surprising; the classical algorithm is, after all, a classic.
It has gone through many years of research and is widely used for a reason.
Furthermore, the tool we used for parsing, Menhir, has minor optimizations to make parsing quicker.
This is not to say that Menhir is always quicker; there may exist a class of programs which are parsed quicker by our algorithm.
Furthermore, with time we believe that optimizations may be found for our algorithm to make it at least competitive with the classical algorithms.
