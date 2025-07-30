#!/bin/bash

echo "🔍 Validating testing framework installation..."

# Determine correct path to shared-frameworks
FRAMEWORKS_DIR=""
if [[ -d "shared-frameworks" ]]; then
    FRAMEWORKS_DIR="shared-frameworks"
elif [[ -d "../shared-frameworks" ]]; then
    FRAMEWORKS_DIR="../shared-frameworks"
else
    echo "❌ Cannot locate shared-frameworks directory"
    exit 1
fi

# Check Unity framework
if [[ -f "$FRAMEWORKS_DIR/unity/src/unity.h" && -f "$FRAMEWORKS_DIR/unity/src/unity.c" ]]; then
    echo "✅ Unity framework found and complete"
else
    echo "❌ Unity framework missing or incomplete"
fi

# Check GoogleTest framework
if [[ -d "$FRAMEWORKS_DIR/googletest" && -f "$FRAMEWORKS_DIR/googletest/CMakeLists.txt" ]]; then
    echo "✅ GoogleTest framework found"
else
    echo "❌ GoogleTest framework missing"
fi

echo "Framework validation complete"
