#!/bin/bash
# Complete Swift Build Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <source.swift> [output_name] [swift_flags]"
    echo "Example: $0 metadata_tool.swift metadata_app"
    echo "Example: $0 audio_processor.swift processor '-O'"
    exit 1
fi

source_file="$1"
output_name="${2:-$(basename "$source_file" .swift)}"
swift_flags="${3:-}"

echo "🔨 Building Swift program: $source_file"
echo "📦 Output: $output_name"

# Check if source file exists
if [[ ! -f "$source_file" ]]; then
    echo "❌ Source file not found: $source_file"
    exit 1
fi

# Build with Swift compiler
swiftc -framework AudioToolbox -framework Foundation \
       -import-objc-header /System/Library/Frameworks/AudioToolbox.framework/Headers/AudioToolbox.h \
       $swift_flags \
       "$source_file" -o "$output_name"

if [[ $? -eq 0 ]]; then
    echo "✅ Successfully built: $output_name"
    echo "🚀 Run with: ./$output_name"
else
    echo "❌ Build failed"
    exit 1
fi
