fun fib (x) {
    if (x < 2) {
        1
    }{
        let y = (fib (x-1)) + (fib (x-2));
        y
    }
}
let x = (fib 10);
_prim_print x
