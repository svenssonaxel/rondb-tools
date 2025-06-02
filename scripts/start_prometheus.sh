#!/usr/bin/env bash
source ./scripts/include.sh

sudo tee /etc/prometheus/prometheus.yml < ${CONFIG_FILES}/prometheus.yml >/dev/null
before-start prometheus
(set -x; sudo systemctl start prometheus; )
after-start prometheus
