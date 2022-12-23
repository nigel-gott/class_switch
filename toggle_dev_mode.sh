#!/bin/bash
set -euo pipefail

toggle_dev_mode() {
  if grep -Fxq "#dependency_overrides:" "$1"; then
    echo "Switching ON dev mode..."
    sed -i 's/#\(.*\)/\1/' "$1"
  else
    echo "Switching OFF dev mode..."
    sed -i '/dependency_overrides:/,$ s/^/#/' "$1"
  fi
}

toggle_dev_mode class_switch_generator/pubspec.yaml
toggle_dev_mode class_switch_project_example/pubspec.yaml
