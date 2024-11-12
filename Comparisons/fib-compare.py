import matplotlib.pyplot as plt
import os
import sys
import time

num_exes = 5
exe_nums = [i for i in range(2,26,3)]

exes = ["../llang", "../llang-classical"]
names = ["Our Algorithm", "Classical Algorithm"]

fig = plt.figure(figsize = (10, 5))

for e in range(len(exes)):
    times = []
    for n in exe_nums:
        print(f"Run {n}")
        code = f"""
        fun fib (x) {{
            if (x < 2) {{
                1
            }}{{
                let y = (fib (x-1)) + (fib (x-2));
                y
            }}
        }}
        let x = (fib {n});
        _prim_print x
        """
        with open("fib.ml", "w") as f:
            f.write(code)
        start = time.time()
        for i in range(num_exes):
            os.system(f"{exes[e]} fib.ml y")
        end = time.time()
        times.append(end - start)
    with open("fib-res.txt", "a") as f:
        f.write(f"{names[e]}: {' '.join([str(f) for f in times])}")
    plt.plot(exe_nums, times, label=names[e])

plt.legend()
print("Saving image to fib.png")
plt.savefig("fib.png")

