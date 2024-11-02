# Start with an OCaml base image
FROM ocaml/opam:debian AS build

# Set up the OPAM environment
RUN opam init -y --disable-sandboxing && opam update

# Set the working directory
WORKDIR /app

# Copy all project files, including the bash script, into the container
COPY --chown=opam:opam . .

RUN eval $(opam env) && opam install dune menhir --yes
RUN eval $(opam env) && dune --version && menhir --version

RUN chmod -R 777 /app/Source
RUN chmod -R 777 /app/Classical-Source
RUN chmod +x /app/run-script.sh

# Install OCaml dependencies if you have them, like with `opam`
RUN eval $(opam env) && opam install . --deps-only -y

# Start with an OCaml base image
WORKDIR /app/Source
RUN eval $(opam env) && make
WORKDIR /app/Classical-Source
RUN eval $(opam env) && make

