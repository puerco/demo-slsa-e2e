#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright 2025 Carabiner Systems, Inc
# SPDX-License-Identifier: Apache-2.0

# Go Docker Cross-Compilation Build Script
# Uses cgr.dev/chainguard/go to build Go code for multiple platforms

set -e  # Exit on any error

# Configuration
GO_IMAGE="cgr.dev/chainguard/go"
BUILD_DIR="/workspace"
OUTPUT_DIR="./bin"

# Target platforms for cross-compilation
PLATFORMS=(
    "linux/amd64"
    "linux/arm64"
    "darwin/amd64"
    "darwin/arm64"
    "windows/amd64"
)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if go.mod exists in current directory
if [ ! -f "go.mod" ]; then
    print_warning "No go.mod found in current directory"
    print_info "This might not be a Go module directory"
fi

# Get the module name from go.mod for binary naming
get_module_name() {
    if [ -f "go.mod" ]; then
        grep "^module " go.mod | awk '{print $2}' | xargs basename
    else
        basename "$(pwd)"
    fi
}

# Build function for a specific platform
build_for_platform() {
    local goos=$1
    local goarch=$2
    local module_name=$3
    
    local binary_name="$module_name"
    
    local output_path="./bin/${binary_name}-${goos}-${goarch}"
    local output_dir="./bin/"

    if [ "$goos" = "windows" ]; then
        output_path="${output_path}.exe"
    fi
    
    print_info " 🚧 Building for ${goos}/${goarch}..."
    
    # Create platform-specific output directory
    mkdir -p "$output_dir"
    
    docker run --rm \
        -v "$(pwd):$BUILD_DIR" \
        -v "$CACHE_DIR:/tmp/go-cache" \
        -w "$BUILD_DIR" \
        -u "$(id -u):$(id -g)" \
        -e GOOS="$goos" \
        -e GOARCH="$goarch" \
        -e GOCACHE=/tmp/go-cache \
        -e GOMODCACHE=/tmp/go-cache/mod \
        -e CGO_ENABLED=0 \
        "$GO_IMAGE" \
        build -o "$output_path" .
    
    if [ $? -eq 0 ]; then
        print_info "✓ Successfully built ${goos}/${goarch} -> $output_path"
        return 0
    else
        print_error "✗ Failed to build ${goos}/${goarch}"
        return 1
    fi
}

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

print_info "Cross-compiling Go application using $GO_IMAGE"
print_info "Current directory: $(pwd)"
print_info "Output directory: $OUTPUT_DIR"

# Get module name for binary naming
MODULE_NAME=$(get_module_name)
print_info "Module name: $MODULE_NAME"

# Create temporary cache directory
CACHE_DIR=$(mktemp -d)

# We don't really need to delete the temp dir, but just in case
# trap "rm -rf $CACHE_DIR || :" EXIT

print_info "Using cache directory: $CACHE_DIR"

# Build for each platform
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

for platform in "${PLATFORMS[@]}"; do
    IFS='/' read -r goos goarch <<< "$platform"
    
    if build_for_platform "$goos" "$goarch" "fritoto"; then
        SUCCESSFUL_BUILDS=$((SUCCESSFUL_BUILDS + 1))
    else
        FAILED_BUILDS=$((FAILED_BUILDS + 1))
    fi
    echo  
    echo 
done

# Summary
echo "================================================"
print_info "Build Summary:"
print_info "✓ Successful builds: $SUCCESSFUL_BUILDS"
if [ $FAILED_BUILDS -gt 0 ]; then
    print_error "✗ Failed builds: $FAILED_BUILDS"
fi

# List all built binaries
if [ -d "$OUTPUT_DIR" ] && [ "$(find $OUTPUT_DIR -type f | wc -l)" -gt 0 ]; then
    echo
    print_info "Built binaries:"
    find "$OUTPUT_DIR" -type f -exec ls -lh {} \; | sort
    
    echo
    print_info "Directory structure:"
    tree "$OUTPUT_DIR" 2>/dev/null || find "$OUTPUT_DIR" -type d | sort
fi

# Exit with error if any builds failed
if [ $FAILED_BUILDS -gt 0 ]; then
    exit 1
fi

print_info "All builds completed successfully!"
