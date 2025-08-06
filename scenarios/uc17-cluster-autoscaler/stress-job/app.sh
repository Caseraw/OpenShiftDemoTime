#!/bin/sh
echo "Starting stress test..."
stress --cpu 1 --vm 1 --vm-bytes 300M --timeout 10
echo "Done."
