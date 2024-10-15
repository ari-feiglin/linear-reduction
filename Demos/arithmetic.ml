fun print (x) {
    _prim_print x
}

fun fib (x) {
    if (x < 2) {
        1
    }{
        (fib (x-1)) + (fib (x-2))
    }
}

print (fib 20);
