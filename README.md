#CPUSTATSd

This script uses the output of ``turbostat`` to provide current CPU load and  minimun and maximum core clock in temporary files in /run/cpustatsd and must be run as root.
I made because I needed a way to get this information as an non-root user (The files it updates are world-readable) so i can use it in my DWM window manager's status bar.
