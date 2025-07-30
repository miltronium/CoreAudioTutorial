#!/bin/bash
# Xcode Project Creation Script for Core Audio Tutorial
set -e

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <project_name> [template_type]"
    echo "Templates: c, cpp, objc, swift"
    echo "Example: $0 MetadataExtractor objc"
    exit 1
fi

project_name="$1"
template_type="${2:-c}"

echo "🔨 Creating Xcode project: $project_name"
echo "📝 Template type: $template_type"

# Create project directory
mkdir -p "$project_name"
cd "$project_name"

# Create basic Xcode project structure based on template
case "$template_type" in
    "c")
        echo "Creating C project template..."
        cat > main.c << 'C_TEMPLATE'
#include <stdio.h>
#include <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    printf("Core Audio C Project\n");
    
    // Add your Core Audio code here
    
    return 0;
}
C_TEMPLATE
        ;;
    "cpp")
        echo "Creating C++ project template..."
        cat > main.cpp << 'CPP_TEMPLATE'
#include <iostream>
#include <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    std::cout << "Core Audio C++ Project" << std::endl;
    
    // Add your Core Audio code here
    
    return 0;
}
CPP_TEMPLATE
        ;;
    "objc")
        echo "Creating Objective-C project template..."
        cat > main.m << 'OBJC_TEMPLATE'
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"Core Audio Objective-C Project");
        
        // Add your Core Audio code here
        
    }
    return 0;
}
OBJC_TEMPLATE
        ;;
    "swift")
        echo "Creating Swift project template..."
        cat > main.swift << 'SWIFT_TEMPLATE'
import Foundation
import AudioToolbox

print("Core Audio Swift Project")

// Add your Core Audio code here
SWIFT_TEMPLATE
        ;;
    *)
        echo "❌ Unknown template type: $template_type"
        exit 1
        ;;
esac

# Create build script
cat > build.sh << 'BUILD_TEMPLATE'
#!/bin/bash
set -e

echo "🔨 Building project..."

case "TEMPLATE_TYPE" in
    "c")
        clang -framework AudioToolbox -framework Foundation main.c -o PROJECT_NAME
        ;;
    "cpp")
        clang++ -framework AudioToolbox -framework Foundation -std=c++14 main.cpp -o PROJECT_NAME
        ;;
    "objc")
        clang -framework AudioToolbox -framework Foundation -fobjc-arc main.m -o PROJECT_NAME
        ;;
    "swift")
        swiftc -framework AudioToolbox -framework Foundation main.swift -o PROJECT_NAME
        ;;
esac

echo "✅ Build complete: ./PROJECT_NAME"
BUILD_TEMPLATE

# Replace placeholders in build script
sed -i '' "s/PROJECT_NAME/$project_name/g" build.sh
sed -i '' "s/TEMPLATE_TYPE/$template_type/g" build.sh
chmod +x build.sh

echo "✅ Xcode project created: $project_name"
echo "📁 Project directory: $(pwd)"
echo "🚀 Build with: ./build.sh"

cd ..
