#!/bin/bash
# Validation Script for All Build Scripts
set -e

echo "🔍 Validating all build scripts..."

SCRIPTS_DIR="$(dirname "$0")"
BUILD_SCRIPTS=(
    "build-c.sh"
    "build-cpp.sh"
    "build-objc.sh"
    "build-swift.sh"
    "setup-cmake.sh"
    "create-xcode-project.sh"
)

ALL_VALID=true

for script in "${BUILD_SCRIPTS[@]}"; do
    script_path="$SCRIPTS_DIR/$script"
    if [[ -f "$script_path" && -x "$script_path" ]]; then
        echo "✅ $script - found and executable"
    else
        echo "❌ $script - missing or not executable"
        ALL_VALID=false
    fi
done

if $ALL_VALID; then
    echo "🎉 All build scripts validated successfully!"
    echo
    echo "📋 Available build scripts:"
    echo "  🔨 build-c.sh - Build C programs"
    echo "  🔨 build-cpp.sh - Build C++ programs"
    echo "  🔨 build-objc.sh - Build Objective-C programs"
    echo "  🔨 build-swift.sh - Build Swift programs"
    echo "  🔧 setup-cmake.sh - Create CMake configuration"
    echo "  📱 create-xcode-project.sh - Generate Xcode projects"
    echo
    echo "🚀 Usage examples:"
    echo "  scripts/build-c.sh my_program.c"
    echo "  scripts/build-swift.sh metadata_tool.swift"
    echo "  scripts/create-xcode-project.sh MyApp objc"
else
    echo "❌ Build script validation failed!"
    exit 1
fi
