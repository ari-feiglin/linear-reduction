fun print (x) {
    _prim_print x
}

fun len (l) {
    _prim_len l
    _reg_out
}

fun type (x) {
    _prim_type x
    _reg_out
}

let num_type1 = Num;
let num_type2 = type 10;

if (num_type1 == num_type2) {
    print 1;
}{
    print 0;
}

fun empty_list_of_type (l) {
    [] : (type l)
}

let arr = [(1, [1;]); (2, [1;2;]);];
let empty_arr = empty_list_of_type arr;
print arr;
print empty_arr;
print (type arr);
print (type empty_arr);

let test = 10 : (List Num);
print test;
print (type test);

fun add (x,y) {
    switch
    | (type x != type y) -> { print 0; }
    | (type x == Num) -> { x + y }
    | 1 -> { x @ y }
    end
}

(add ([1; 2;], [3;]));
(add (1, 2));

