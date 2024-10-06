import matplotlib.pyplot as plt
import os
import sys
import time

if len(sys.argv) < 2:
    print("Must provide file name to run")
    sys.exit(1)

num_exes = 30

exes = ["../llang", "../llang-classical"]
exe_names = ["Our Algorithm", "Classical Algorithm"]
times = []

for exe in exes:
    start = time.time()
    for i in range(num_exes):
        print(f"Run {i}")
        os.system(f"{exe} {sys.argv[1]} y")
    times.append(time.time() - start)

fig = plt.figure(figsize = (10, 5))
plt.bar(exe_names, times, color="red")
plt.show()
