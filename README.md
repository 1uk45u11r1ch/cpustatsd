# CPUSTATSd

This script uses the output of ``turbostat`` to provide current CPU load and  minimun and maximum core clock in temporary files in ``/run/cpustatsd`` and must be run as root.
I made this because I needed a way to get this information as an non-root user (the files it updates are world-readable) to be shown in the DWM window manager's status bar.

The included systemd unit file requires this repo to be found in ``/usr/local/src/cpustatsd``.
