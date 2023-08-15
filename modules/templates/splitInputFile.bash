#!/usr/bin/env bash

set -euo pipefail

split -l $downloadsPerSplit $inputFile smaller
