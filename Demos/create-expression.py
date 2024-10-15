import sys
from random import randint, choice 

if len(sys.argv) < 3:
    print("Invalid number of arguments")
    sys.exit(1)

string = "let x = "
length = int(sys.argv[1])
depth = int(sys.argv[2])
ops = ["+", "-", "*", "/"]

def create_expr(l, d, n=100):
    if d == 0:
        if l == 0:
            return str(randint(0, n))
        return str(randint(0, n)) + choice(ops) + create_expr(l-1, d, n)
    string = "(" + create_expr(l, d-1, n) + ")"
    for i in range(l - 1):
        string += choice(ops) + "(" + create_expr(l, d-1, n) + ")"
    return string

with open("expression.txt", "w") as f:
    string += create_expr(length, depth) + ";"
    f.write(string)
