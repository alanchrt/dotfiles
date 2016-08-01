#!/bin/sh
case $1/$2 in
  pre/*)
    echo "Going to $2..."
    modprobe -r facetimehd
    ;;
  post/*)
    echo "Waking up from $2..."
    modprobe -r bdc_pci
    modprobe facetimehd
    ;;
esac
