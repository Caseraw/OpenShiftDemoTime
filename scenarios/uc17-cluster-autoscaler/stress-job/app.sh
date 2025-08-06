#!/bin/sh
echo "Starting stress test..."
stress --cpu 2 --vm 1 --vm-bytes 3800M --timeout 300
echo "Done."
