# How to use

Internally:
```
dpkg-buildpackage -b -uc -us
sudo apt install ../rpi-{loop-utils,swap}_0.0.1_all.deb
```

*REBOOT*

rpi-swap replaces dphys-swap. It's (self-documenting) configuration file is in /etc/rpi-swap/swap.conf

The configuration is parsed during very early boot by
/lib/systemd/system-generators/rpi-swap-generator and unit
files are generated.

rpi-swap currently supports 'swapfile', 'zram',
'zram+swap', and 'auto'. The default configuration is
'auto' as this will allow us to freely make changes to
configuration based on device-class going forwards.

rpi-loop-utils uses udev to create /dev/disk/by-backingfile
symlinks when loop devices are setup. It also provides a
templated systemd service for setting up specific files on
loop devices (such as /var/swap)

Is it working (zram+file)?
```
# Is zram0 being used as swap?
grep --quiet '/dev/zram0' /proc/swaps && echo "OK" || echo "FAIL"

# Is /dev/loop0 being used as zram0's backing device?
grep --quiet '/dev/loop0' /sys/block/zram0/backing_dev && echo "OK" || echo "FAIL"

# Is /var/swap the file behind /dev/loop0?
grep --quiet '/var/swap' /sys/block/loop0/loop/backing_file && echo "OK" || echo "FAIL"

# Does systemd think the swap unit is working?
systemctl status dev-zram0.swap

# Has the swap target been reached?
systemctl status swap.target
```

# Known Issues

No customisation for zram swap is currently supported in
the configuration file.
