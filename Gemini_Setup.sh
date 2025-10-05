#!/bin/bash

# -------------------------------
# Full-Powered Gemini CLI Termux Setup with Storage Access
# -------------------------------

# Colors for output
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${GREEN}>>> Updating Termux packages...${NC}"
pkg update && pkg upgrade -y

echo -e "${GREEN}>>> Installing Node.js, npm, and build tools...${NC}"
pkg install nodejs clang make python git -y

# Verify Node.js
echo -e "${YELLOW}Node.js version:${NC} $(node -v)"
echo -e "${YELLOW}npm version:${NC} $(npm -v)"

# Step: Request storage permission
echo -e "${GREEN}>>> Requesting Termux storage access...${NC}"
termux-setup-storage || echo -e "${YELLOW}Warning: termux-setup-storage command may require manual confirmation.${NC}"

# Step: Create project folder
PROJECT_DIR=~/gemini-project
echo -e "${GREEN}>>> Creating project folder at $PROJECT_DIR ...${NC}"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Step: Set GEMINI API Key
read -p "Enter your GEMINI API Key: " GEMINI_KEY
export GEMINI_API_KEY="$GEMINI_KEY"
echo "export GEMINI_API_KEY=\"$GEMINI_KEY\"" >> ~/.bashrc
source ~/.bashrc
echo -e "${GREEN}>>> GEMINI_API_KEY set in environment.${NC}"

# Step: Create .env file
echo -e "${GREEN}>>> Creating .env file...${NC}"
cat > .env <<EOL
GEMINI_API_KEY=$GEMINI_KEY
GEMINI_PROJECT_ID=my-gemini-project
EOL
echo -e "${GREEN}>>> .env file created.${NC}"

# Step: Install Gemini CLI
echo -e "${GREEN}>>> Installing Gemini CLI...${NC}"
npm install -g @google/gemini-cli

# Step: Fix common node-pty build issues
echo -e "${GREEN}>>> Rebuilding node-pty if needed...${NC}"
npm rebuild || echo -e "${YELLOW}Warning: node-pty rebuild failed, ignoring minor errors.${NC}"

# Step: Initialize Gemini project with retry for overloaded model
echo -e "${GREEN}>>> Initializing Gemini project...${NC}"
MAX_RETRIES=5
COUNT=1
while [ $COUNT -le $MAX_RETRIES ]; do
    echo -e "${YELLOW}Attempt $COUNT of $MAX_RETRIES...${NC}"
    npx @google/gemini-cli init && break
    echo -e "${RED}Gemini model overloaded or auth waiting. Retrying in 15 seconds...${NC}"
    sleep 15
    COUNT=$((COUNT+1))
done

echo -e "${GREEN}>>> Setup complete!${NC}"
echo -e "${YELLOW}To start using Gemini CLI:${NC}"
echo -e "cd $PROJECT_DIR"
echo -e "npx @google/gemini-cli <command>"
echo -e "${YELLOW}All files can now access Termux storage folders (shared storage)${NC}"