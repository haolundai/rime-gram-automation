#!/usr/bin/env bash
set -eEuo pipefail
./scripts/doctor.sh
./train_gram.sh
