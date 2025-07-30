#!/bin/bash
# Complete Objective-C Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.m> [output_name] [additional_frameworks]"
    echo "Example: $0 metadata_manager.m metadata_app"
    echo "Example: $0 audio_service.m service '-framework CloudKit'"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .m)}"
additional_frameworks="${3:-}"

echo "🔨 Building Objective-C program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Core Audio and Foundation frameworks
clang -framework AudioToolbox -framework Foundation -framework Cocoa \
      -fobjc-arc -Wall -Wextra \
      $additional_frameworks \
      "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
