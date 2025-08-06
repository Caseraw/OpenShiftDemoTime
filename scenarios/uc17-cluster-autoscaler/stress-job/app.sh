#!/bin/sh
echo "Starting stress test..."
stress --cpu 2 --vm 1 --vm-bytes 5500M --timeout 90
echo "Done."
