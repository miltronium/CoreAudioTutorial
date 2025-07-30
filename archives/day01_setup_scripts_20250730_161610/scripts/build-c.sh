#!/bin/bash
# Complete C Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.c> [output_name] [additional_flags]"
    echo "Example: $0 metadata_extractor.c metadata_tool"
    echo "Example: $0 test_audio.c test_tool -DDEBUG"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .c)}"
additional_flags="${3:-}"

echo "🔨 Building C program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Core Audio frameworks
clang -framework AudioToolbox -framework Foundation \
      -Wall -Wextra -std=c99 \
      $additional_flags \
      "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
