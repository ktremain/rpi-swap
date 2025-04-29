# How to use

Internally:
```
dpkg-buildpackage -b -uc -us
sudo apt install ../rpi-{zram-swap,loop-var-swap,symlink-loop-devices}_0.0.1_all.deb
```

*REBOOT*

Is it working?
```
# Is zram0 being used as swap?
grep --quiet '/dev/zram0' /proc/swaps && echo "OK" || echo "FAIL"

# Is /dev/loop0 being used as zram0's backing device?
grep --quiet '/dev/loop0' /sys/block/zram0/backing_dev && echo "OK" || echo "FAIL"

# Is /var/swap the file behind /dev/loop0?
grep --quiet '/var/swap' /sys/block/loop0/loop/backing_file && echo "OK" || echo "FAIL"
```

To switch back to regular swap:
```
sudo apt remove rpi-zram-swap
apt-mark showauto | grep --max-count=1 --silent '^systemd-zram-generator$' && sudo apt remove systemd-zram-generator
# Reboot (due to issue decribed below)
sudo apt install dphys-swapfile
```

# Known Issues

*URGENT*, doing 'apt install dphys-swapfile' will cause our packages to be
removed (but /var/swap backed zram0 remains active). dphys-swapfile immediately
starts using it. This could lead to system instability as it's being used as
swap twice over.
