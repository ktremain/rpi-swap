#!/bin/bash
# Swap configuration diagnostics

echo "=== Current Swap Status ==="
swapon -s
echo ""

echo "=== Swap Partitions Detected by blkid ==="
blkid -t TYPE=swap -o device 2>/dev/null | grep -v '^/dev/zram'
echo ""

echo "=== Block Devices ==="
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
echo ""

echo "=== Configured Swap Mechanism ==="
if [ -f /etc/rpi/swap.conf ]; then
    echo "Main config:"
    grep -v '^#' /etc/rpi/swap.conf | grep -v '^$'
else
    echo "No /etc/rpi/swap.conf found"
fi
echo ""

echo "Drop-ins:"
if [ -d /etc/rpi/swap.conf.d ]; then
    for f in /etc/rpi/swap.conf.d/*.conf; do
        if [ -f "$f" ]; then
            echo "=== $f ==="
            grep -v '^#' "$f" | grep -v '^$'
        fi
    done
else
    echo "No drop-ins"
fi
echo ""

echo "=== Generated Swap Units ==="
systemctl list-units --type swap --all
echo ""

echo "=== Swap Unit Files in /run/systemd/generator ==="
ls -la /run/systemd/generator/*.swap 2>/dev/null || echo "No swap units found"
if [ -f /run/systemd/generator/dev-zram0.swap ]; then
    echo ""
    echo "=== dev-zram0.swap content ==="
    cat /run/systemd/generator/dev-zram0.swap
fi
echo ""

echo "=== Zram Configuration ==="
if [ -d /run/systemd/zram-generator.conf.d ]; then
    ls -la /run/systemd/zram-generator.conf.d/
    echo ""
    for f in /run/systemd/zram-generator.conf.d/*.conf; do
        if [ -f "$f" ]; then
            echo "=== $f ==="
            cat "$f"
        fi
    done
else
    echo "No zram generator config found"
fi
echo ""

echo "=== Test Generator Manually ==="
echo "Running: /lib/systemd/system-generators/rpi-swap-generator /tmp/gen /tmp/gen-early /tmp/gen-late"
rm -rf /tmp/gen /tmp/gen-early /tmp/gen-late
mkdir -p /tmp/gen /tmp/gen-early /tmp/gen-late
/lib/systemd/system-generators/rpi-swap-generator /tmp/gen /tmp/gen-early /tmp/gen-late
echo ""
echo "Generated files:"
find /tmp/gen -type f -exec echo "=== {} ===" \; -exec cat {} \;
echo ""

echo "=== Systemd Zram Setup Service ==="
systemctl status systemd-zram-setup@zram0.service --no-pager
echo ""

echo "=== Journal Logs for Generator ==="
journalctl -b -u systemd-generator --no-pager | tail -20
