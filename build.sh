#!/bin/bash

# Guardian Voice UC - Build & Test Script
# Run from: /Users/davidsmith/Documents/GitHub/guardian_voice_uc

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Guardian Voice UC - Build & Test${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Step 1: Check Flutter
echo -e "${YELLOW}Step 1: Checking Flutter installation...${NC}"
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓ Flutter found$(NC)"
    flutter --version
else
    echo -e "${RED}✗ Flutter not found. Please install Flutter first.${NC}"
    echo "Visit: https://flutter.dev/docs/get-started/install/macos"
    exit 1
fi

# Step 2: Clean build
echo ""
echo -e "${YELLOW}Step 2: Cleaning previous build...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"

# Step 3: Get dependencies
echo ""
echo -e "${YELLOW}Step 3: Getting dependencies...${NC}"
flutter pub get
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies resolved${NC}"
else
    echo -e "${RED}✗ Failed to get dependencies${NC}"
    echo "Possible issues:"
    echo "1. Check your internet connection"
    echo "2. Verify pubspec.yaml is valid"
    echo "3. Check plugin structure at plugins/gv_core"
    exit 1
fi

# Step 4: Check TURN configuration
echo ""
echo -e "${YELLOW}Step 4: Checking TURN configuration...${NC}"
if grep -q '"TURN_PASSWORD": "WILL_BE_GENERATED_FROM_SERVER"' env.json; then
    echo -e "${YELLOW}⚠ TURN password not set${NC}"
    echo "After server setup, run: ./scripts/update_turn_password.sh --fetch"
else
    echo -e "${GREEN}✓ TURN configuration found${NC}"
fi

# Step 5: Build menu
echo ""
echo -e "${CYAN}Select build option:${NC}"
echo "1) Android Debug APK"
echo "2) Android Release APK"
echo "3) iOS Debug"
echo "4) iOS Release"
echo "5) Run tests"
echo "6) Exit"
echo ""
read -p "Enter choice [1-6]: " choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}Building Android Debug APK...${NC}"
        flutter build apk --debug
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Build successful!${NC}"
            echo "APK location: build/app/outputs/flutter-apk/app-debug.apk"
            echo ""
            echo "Install with: adb install build/app/outputs/flutter-apk/app-debug.apk"
        else
            echo -e "${RED}✗ Build failed${NC}"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}Building Android Release APK...${NC}"
        echo -e "${YELLOW}Note: Requires signing configuration${NC}"
        flutter build apk --release
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Build successful!${NC}"
            echo "APK location: build/app/outputs/flutter-apk/app-release.apk"
        else
            echo -e "${RED}✗ Build failed${NC}"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo -e "${YELLOW}Building iOS Debug...${NC}"
        flutter build ios --debug --no-codesign
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Build successful!${NC}"
            echo "Open ios/Runner.xcworkspace in Xcode to run on device"
        else
            echo -e "${RED}✗ Build failed${NC}"
            exit 1
        fi
        ;;
    4)
        echo ""
        echo -e "${YELLOW}Building iOS Release...${NC}"
        echo -e "${YELLOW}Note: Requires signing configuration${NC}"
        flutter build ios --release
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Build successful!${NC}"
        else
            echo -e "${RED}✗ Build failed${NC}"
            exit 1
        fi
        ;;
    5)
        echo ""
        echo -e "${YELLOW}Running tests...${NC}"
        flutter test
        ;;
    6)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Done!${NC}"
echo -e "${CYAN}========================================${NC}"
