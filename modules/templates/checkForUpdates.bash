#!/usr/bin/env bash

set -euo pipefail

perl /usr/bin/checkForUpdate.pl --inputFile $inputFile --storageDir storage --outputFile needsUpdate.txt --ebiFtpUser $ebiFtpUser --ebiFtpPassword $ebiFtpPassword
