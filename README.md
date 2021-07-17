# x86-Cooperative-Multitasking

## Overview

This was a 2-person group project where my contribution was substantial. <br>
This program implements 4 tasks:
1. **Task 1: Alphabet** <br>
    This task continously prints the alphabet from A-Z and Z-A. 
2. **Task 2: Graphics** <br>
    this task recursively generates circles of different radii and colors in a fractal fashion.
3. **Task 3: RPN (Reverse Polish notation) Calculator** <br>
    Example: The input **33(space)7(space)+** would result in 40.
4.  **Task 4: Sound** <br>
    This task plays a sound file.

The context switch is achieved by each of the tasks yielding periodically to the next task.

# Usage

1. Install DosBox 
2. In DosBox, navigate to the base folder, and execute Kernel.exe
3. The program waits for a key press before executing the tasks

# Result

![result](result.png "result")
