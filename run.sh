#!/usr/bin/env bash
set -eEuo pipefail
bash ./scripts/doctor.sh
bash ./train_gram.sh
