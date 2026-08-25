#!/bin/sh
# Flash a .uf2 to both halves of a Glove80 on macOS.
#
#   ./flash.sh firmware-archive/baseline-v25.11-factory-macos-swapped-command.uf2
#   ./flash.sh firmware-archive/sunaku-glorious-engrammer-qwerty.uf2
#
# Run with no argument to pick from what's in firmware-archive/.
#
# Each half must be put into bootloader mode separately; when it is, macOS
# mounts it as /Volumes/GLV80LHBOOT (left) or /Volumes/GLV80RHBOOT (right).
# Copying a .uf2 there flashes it and the volume disappears on its own.

set -eu

cd "$(dirname "$0")"

fw="${1:-}"

if [ -z "$fw" ]; then
    echo "Available firmware:"
    echo
    i=0
    for f in firmware-archive/*.uf2; do
        i=$((i + 1))
        echo "  $i) $f"
    done
    [ "$i" -eq 0 ] && { echo "  (none found in firmware-archive/)"; exit 1; }
    echo
    printf "Which one? [1-%s] " "$i"
    read -r choice
    fw=$(ls firmware-archive/*.uf2 | sed -n "${choice}p")
fi

[ -f "$fw" ] || { echo "No such file: $fw" >&2; exit 1; }

echo
echo "Flashing: $fw"
echo "SHA-256:  $(shasum -a 256 "$fw" | cut -d' ' -f1)"
echo

# Flash one half. $1 is the volume name, $2 is a human label.
flash_half() {
    vol="/Volumes/$1"
    label="$2"

    if [ -d "$vol" ]; then
        echo "==> $label already in bootloader mode."
    else
        echo "==> Put the $label half into bootloader mode now."
        echo "    (Magic + a per-half key — check MoErgo's docs if unsure:"
        echo "     docs.moergo.com, 'Putting into bootloader for firmware loading')"
        printf "    Waiting for %s ..." "$1"
        while [ ! -d "$vol" ]; do
            sleep 1
            printf "."
        done
        echo " found."
    fi

    # The copy typically errors as the device reboots mid-write; that is
    # normal and means it worked, so don't let set -e kill the script.
    cp "$fw" "$vol/flash.uf2" 2>/dev/null || true
    sync 2>/dev/null || true
    echo "==> $label flashed."
    echo
}

flash_half GLV80LHBOOT "LEFT"
flash_half GLV80RHBOOT "RIGHT"

echo "Done. Both halves flashed with:"
echo "  $fw"
