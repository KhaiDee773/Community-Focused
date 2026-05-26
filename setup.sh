#!/bin/bash

# ============================================
# Community Focused (CF) - Setup Script
# ============================================
# Description: Automated setup for development environment
# Usage: chmod +x setup.sh && ./setup.sh
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# Helper Functions
# ============================================

print_header() {
    echo -e "${BLUE}"
    echo "============================================"
    echo "$1"
    echo "============================================"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# ============================================
# Main Setup
# ============================================

print_header "Community Focused (CF) Setup"

# Check if Node.js is installed
print_info "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js >= 18"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d 'v' -f 2 | cut -d '.' -f 1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js version must be >= 18. Current version: $(node -v)"
    exit 1
fi
print_success "Node.js version: $(node -v)"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed"
    exit 1
fi
print_success "npm version: $(npm -v)"

# Install dependencies
print_header "Installing Dependencies"
print_info "This may take a few minutes..."
npm install
print_success "Dependencies installed"

# Setup environment file
print_header "Environment Configuration"

if [ -f ".env" ]; then
    print_warning ".env file already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Keeping existing .env file"
    else
        cp .env.example .env
        print_success "Created .env from template"
    fi
else
    cp .env.example .env
    print_success "Created .env from template"
fi

# Prompt for Supabase credentials
print_header "Supabase Configuration"
print_warning "You need to create a Supabase project first at: https://app.supabase.com"
read -p "Enter your Supabase URL: " SUPABASE_URL
read -p "Enter your Supabase Anon Key: " SUPABASE_ANON_KEY

# Update .env file
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|SUPABASE_URL=.*|SUPABASE_URL=$SUPABASE_URL|g" .env
    sed -i '' "s|SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY|g" .env
else
    # Linux
    sed -i "s|SUPABASE_URL=.*|SUPABASE_URL=$SUPABASE_URL|g" .env
    sed -i "s|SUPABASE_ANON_KEY=.*|SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY|g" .env
fi

print_success "Environment variables configured"

# iOS setup (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    print_header "iOS Setup (CocoaPods)"
    
    if ! command -v pod &> /dev/null; then
        print_warning "CocoaPods not found. Installing..."
        sudo gem install cocoapods
    fi
    
    print_info "Installing iOS dependencies..."
    cd ios
    pod install
    cd ..
    print_success "iOS dependencies installed"
else
    print_info "Skipping iOS setup (not on macOS)"
fi

# Database schema reminder
print_header "Database Setup Required"
print_warning "Don't forget to run the database schema!"
print_info "Steps:"
print_info "1. Go to Supabase Dashboard > SQL Editor"
print_info "2. Copy contents of supabase_schema.sql"
print_info "3. Run the SQL script"
print_info ""
print_info "File location: $(pwd)/supabase_schema.sql"

# Git setup reminder
print_header "Git Setup"
if [ ! -d ".git" ]; then
    print_info "Initializing Git repository..."
    git init
    print_success "Git repository initialized"
else
    print_success "Git repository already initialized"
fi

# Check if .env is in .gitignore
if grep -q "^\.env$" .gitignore; then
    print_success ".env is in .gitignore"
else
    print_warning ".env is NOT in .gitignore!"
    echo ".env" >> .gitignore
    print_success "Added .env to .gitignore"
fi

# Final instructions
print_header "Setup Complete! 🎉"
print_success "Environment configured successfully"
echo ""
print_info "Next Steps:"
echo "  1. Run database schema in Supabase (see supabase_schema.sql)"
echo "  2. Create storage buckets in Supabase Dashboard:"
echo "     - avatars (public)"
echo "     - post_media (public)"
echo "     - chat_media (private)"
echo ""
print_info "To start the app:"
echo "  iOS:     npm run ios"
echo "  Android: npm run android"
echo "  Metro:   npm start"
echo ""
print_warning "Important Security Reminders:"
echo "  - Never commit .env to Git"
echo "  - Keep your Supabase keys secure"
echo "  - Read SECURITY.md for best practices"
echo ""
print_success "Happy coding! 🚀"
