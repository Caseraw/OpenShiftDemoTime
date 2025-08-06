#!/bin/sh
echo "Starting stress test..."
stress --cpu 2 --vm 2 --vm-bytes 225M --timeout 300
echo "Done."
