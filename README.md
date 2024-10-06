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



