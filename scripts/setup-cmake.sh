#!/bin/bash
# CMake Setup Script for C/C++ Projects
set -e

echo "🔧 Setting up CMake build system"

# Create CMakeLists.txt template
cat > CMakeLists.txt << 'CMAKE_TEMPLATE'
cmake_minimum_required(VERSION 3.16)
project(CoreAudioProject)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required frameworks
find_library(AUDIO_TOOLBOX AudioToolbox)
find_library(FOUNDATION Foundation)

if(NOT AUDIO_TOOLBOX)
    message(FATAL_ERROR "AudioToolbox framework not found")
endif()

if(NOT FOUNDATION)
    message(FATAL_ERROR "Foundation framework not found")
endif()

# Compiler flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra")

# Add executable function
function(add_core_audio_executable target_name source_file)
    add_executable(${target_name} ${source_file})
    target_link_libraries(${target_name} ${AUDIO_TOOLBOX} ${FOUNDATION})
endfunction()

# Example usage (uncomment and modify as needed):
# add_core_audio_executable(metadata_tool metadata_extractor.c)
CMAKE_TEMPLATE

echo "✅ CMakeLists.txt template created"
echo "📝 To use:"
echo "   1. Modify CMakeLists.txt to add your executables"
echo "   2. mkdir build && cd build"
echo "   3. cmake .."
echo "   4. make"
