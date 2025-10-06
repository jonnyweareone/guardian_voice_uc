#!/bin/bash

# Guardian Voice UC - TURN Password Update Script
# This script fetches the TURN password from the server and updates env.json

# Configuration
GUARDIAN_DOMAIN="${GUARDIAN_DOMAIN:-guardianvoice.com}"
TURN_SERVER="${TURN_SERVER:-turn.$GUARDIAN_DOMAIN}"
SSH_USER="${SSH_USER:-ubuntu}"
ENV_FILE="env.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Guardian Voice UC - TURN Password Updater${NC}"
echo "================================================"

# Function to fetch TURN password from server
fetch_turn_password() {
    echo -e "${YELLOW}Fetching TURN password from server...${NC}"
    
    # SSH to the server and get the TURN password
    TURN_PASSWORD=$(ssh $SSH_USER@$TURN_SERVER "sudo grep -m1 '^user=guardian:' /etc/turnserver.conf | cut -d: -f2")
    
    if [ -z "$TURN_PASSWORD" ]; then
        echo -e "${RED}Failed to fetch TURN password from server${NC}"
        echo "Please ensure:"
        echo "1. You have SSH access to $TURN_SERVER"
        echo "2. The turnserver.conf file exists"
        echo "3. The guardian user is configured"
        return 1
    fi
    
    echo -e "${GREEN}Successfully fetched TURN password${NC}"
    return 0
}

# Function to update env.json file
update_env_file() {
    local password=$1
    
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}Error: $ENV_FILE not found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Updating $ENV_FILE...${NC}"
    
    # Backup the original file
    cp $ENV_FILE ${ENV_FILE}.backup
    
    # Update the TURN_PASSWORD in JSON using sed (macOS compatible)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS version
        sed -i '' "s/\"TURN_PASSWORD\": \"[^\"]*\"/\"TURN_PASSWORD\": \"$password\"/" $ENV_FILE
    else
        # Linux version
        sed -i "s/\"TURN_PASSWORD\": \"[^\"]*\"/\"TURN_PASSWORD\": \"$password\"/" $ENV_FILE
    fi
    
    echo -e "${GREEN}Successfully updated $ENV_FILE${NC}"
    return 0
}

# Main execution
main() {
    case "${1:-}" in
        --fetch)
            if fetch_turn_password; then
                update_env_file "$TURN_PASSWORD"
                echo -e "${GREEN}✓ TURN password updated successfully${NC}"
                echo "Password: $TURN_PASSWORD"
            fi
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --fetch       Fetch TURN password from server and update env.json"
            echo "  --help        Show this help message"
            ;;
        *)
            echo "Fetching and updating TURN password..."
            if fetch_turn_password; then
                update_env_file "$TURN_PASSWORD"
                echo -e "${GREEN}✓ Configuration updated successfully${NC}"
                echo ""
                echo "Next steps:"
                echo "1. Rebuild your Flutter app: flutter build"
            fi
            ;;
    esac
}

# Run main function
main "$@"
