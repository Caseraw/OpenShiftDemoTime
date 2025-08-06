#!/bin/sh
echo "Starting stress test..."
stress --cpu 1 --vm 1 --vm-bytes 450M --timeout 300
echo "Done."
