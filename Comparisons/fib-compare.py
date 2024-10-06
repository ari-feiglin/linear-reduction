import matplotlib.pyplot as plt
import os
import sys
import time

num_exes = 5
exe_nums = [i for i in range(2,29,3)]

exes = ["../llang", "../llang-classical"]

fig = plt.figure(figsize = (10, 5))

for exe in exes:
    times = []
    for n in exe_nums:
        print(f"Run {n}")
        code = f"""
        fun fib (x) {{
            if (x < 2) {{
                1
            }}{{
                (fib (x-1)) + (fib (x-2))
            }}
        }}
        let x = (fib {n});
        _prim_print x
        """
        with open("fib.ml", "w") as f:
            f.write(code)
        start = time.time()
        for i in range(num_exes):
            os.system(f"{exe} fib.ml y")
        end = time.time()
        times.append(end - start)
    with open("fib-res.txt", "a") as f:
        f.write(f"{exe}: {' '.join([str(f) for f in times])}")
    plt.plot(exe_nums, times)

plt.show()

