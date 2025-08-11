# rpi-swap

Modern swap management for Raspberry Pi systems, designed to replace `dphys-swapfile` with a more flexible and efficient approach.

## What is rpi-swap?

The `rpi-swap` package provides intelligent swap configuration that adapts to your Raspberry Pi's memory and storage setup. It offers multiple swap mechanisms and integrates seamlessly with systemd's modern service management.

### Key Features

- **Dynamic sizing**: Automatically calculates optimal swap size based on available RAM and storage
- **Multiple swap types**: Supports compressed RAM swap (zram), file-based swap, or hybrid combinations
- **Early boot integration**: Swap is available immediately during the boot process when memory pressure is highest
- **Storage-aware**: Intelligently chooses swap mechanisms based on your storage type (SD card vs USB/SSD)
- **systemd integration**: Full integration with systemd's swap.target for reliable service dependencies
- **Zero-configuration**: Works out of the box with sensible defaults for most Raspberry Pi setups

## How it Works

The system offers four main swap mechanisms:

**🗜️ Compressed RAM Swap (zram)**
Uses a portion of your RAM to create compressed swap space. Ideal for systems with limited storage or SD cards where you want to minimise write wear.

**💾 File-based Swap**
Traditional swap file on disk storage. Best for systems with fast storage like USB drives or SSDs where you want maximum swap capacity.

**🔄 Hybrid (zram + file)**
Combines both approaches - compressed RAM swap for immediate needs, with a backing file that allows idle pages to be moved out of zram over time. This frees up precious zram space for active use, making it particularly beneficial on memory-constrained systems.

**🚫 No Swap (none)**
Completely disables swap functionality. Useful for systems with abundant RAM or specialised applications where swap is not desired. Any existing swap files will be automatically removed.

## What's Included

### rpi-swap (main package)
The core swap management system that:
- Automatically detects your system's memory and storage configuration
- Creates and manages swap devices during early boot
- Provides writeback capabilities to move data from compressed RAM to storage when beneficial
- Replaces the functionality of `dphys-swapfile` with a more modern approach

### rpi-loop-utils (supporting package)
Infrastructure for reliable loop device management:
- Creates stable, persistent names for loop devices based on their backing files
- Ensures loop devices can be reliably referenced in systemd units and scripts
- Provides the foundation for file-based swap functionality

## Why Replace dphys-swapfile?

While `dphys-swapfile` has served Raspberry Pi well, modern systems benefit from:

- **Better memory utilisation**: zram compression uses spare CPU cycles to make better use of your available RAM
- **Reduced storage wear**: Especially important for SD card longevity
- **Faster swap performance**: Compressed RAM swap is much faster than disk-based swap
- **Modern systemd integration**: Full integration with systemd's swap.target and service dependencies
- **Multiple swap mechanisms**: Choose the best approach for your specific hardware and use case
- **Hybrid capabilities**: Advanced writeback features to optimise memory usage over time

## Configuration

For most users, rpi-swap works automatically with no configuration required.

Advanced configuration is available through configuration drop-ins as documented in `swap.conf(5)` and will typically be managed through `raspi-config` in future Raspberry Pi OS releases.

### Making Configuration Changes

**⚠️ Important: After making any changes to swap configuration, you must reboot your system for the changes to take effect.**

While `systemctl daemon-reload` will regenerate the systemd units, it won't stop existing swap units or start new ones. The swap generator runs during early boot when memory pressure is minimal - attempting to reconfigure active swap later can cause system instability.

Configuration files are located at:
- `/etc/rpi/swap.conf` - Main configuration file
- `/etc/rpi/swap.conf.d/*.conf` - Drop-in configuration files (recommended for local changes)

For examples and detailed configuration options, see `man swap.conf`.

## System Requirements

- Raspberry Pi running a systemd-based Linux distribution
- systemd-zram-generator package (automatically installed as dependency)
- Modern kernel with zram support (standard in Raspberry Pi OS)

## Status

This package is designed to be included by default in future Raspberry Pi OS releases as the standard swap management solution, providing better performance and reliability than the current `dphys-swapfile` approach.

---

*For technical documentation, see the included manual pages: `man rpi-swap-generator` and `man swap.conf`*
