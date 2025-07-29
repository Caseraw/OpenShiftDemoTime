#!/bin/env bash

# The actual main function of this file
show_divider() {
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}
