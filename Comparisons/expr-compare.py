import matplotlib.pyplot as plt
import os
import sys
import time

num_exes = 5
exe_nums = [i for i in range(2,6)]

exes = ["../llang", "../llang-classical"]
names = ["Our Algorithm", "Classical Algorithm"]

fig = plt.figure(figsize = (10, 5))

for e in range(len(exes)):
    times = []
    for n in exe_nums:
        print(f"Run {n}")
        os.system(f"python3 ../Demos/create-expression.py {n} {n}")
        start = time.time()
        for i in range(num_exes):
            os.system(f"{exes[e]} expression.txt y")
        end = time.time()
        times.append(end - start)
    with open("expr-res.txt", "a") as f:
        f.write(f"{names[e]}: {' '.join([str(f) for f in times])}")
    plt.plot(exe_nums, times, label=names[e])

plt.legend()
plt.show()


