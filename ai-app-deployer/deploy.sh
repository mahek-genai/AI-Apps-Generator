#!/bin/bash

# Robust AWS CloudFormation Deployment Script for AI App
# This script handles large templates by using S3 and includes better error handling

set -e  # Exit on any error

# Configuration
STACK_NAME="Ai-App-Deployer"
TEMPLATE_FILE="ai-app-deployer.template"
PARAMETERS_FILE="parameters.json"
REGION="us-east-1"  # Change this to your preferred region
S3_BUCKET_PREFIX="ai-deploy"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

# Function to generate unique bucket name (AWS S3 compliant)
generate_bucket_name() {
    local prefix="$1"
    # Use shorter timestamp format (YYYYMMDDHHMMSS)
    local timestamp=$(date +%Y%m%d%H%M%S)
    # Use shorter random suffix (3 digits)
    local random_suffix=$(shuf -i 100-999 -n 1)
    # Get short hostname (first 8 chars, lowercase, alphanumeric only)
    local hostname=$(hostname | cut -d. -f1 | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g' | cut -c1-8)
    # Use last 4 digits of process ID
    local process_id=$(echo $$ | tail -c 5)
    
    # Create bucket name with max 63 characters
    local bucket_name="${prefix}-${timestamp}-${random_suffix}-${hostname}-${process_id}"
    
    # Ensure it's under 63 characters and AWS compliant
    if [ ${#bucket_name} -gt 63 ]; then
        # Truncate if too long, keeping the most unique parts
        local short_timestamp=$(date +%m%d%H%M%S)
        bucket_name="${prefix}-${short_timestamp}-${random_suffix}-${hostname}"
    fi
    
    # Final validation: ensure it's lowercase and AWS compliant
    bucket_name=$(echo "$bucket_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    echo "$bucket_name"
}

# Function to cleanup resources on exit
cleanup() {
    if [ ! -z "$BUCKET_NAME" ] && [ ! -z "$TEMPLATE_KEY" ]; then
        print_status "Cleaning up S3 resources... (bucket: $BUCKET_NAME)"
        aws s3 rm "s3://$BUCKET_NAME/$TEMPLATE_KEY" 2>/dev/null || true
        aws s3 rb "s3://$BUCKET_NAME" 2>/dev/null || true
        print_debug "Cleanup completed at $(date)"
    fi
}

# Set trap to cleanup on exit
trap cleanup EXIT

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials are not configured. Please run 'aws configure' first."
    exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "Template file '$TEMPLATE_FILE' not found."
    exit 1
fi

# Check if parameters file exists
if [ ! -f "$PARAMETERS_FILE" ]; then
    print_error "Parameters file '$PARAMETERS_FILE' not found."
    exit 1
fi

# Prompt for email address
print_status "Email address is required for deployment notifications."
read -p "Enter your email address: " USER_EMAIL

# Validate email format (basic validation)
if [[ ! "$USER_EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    print_error "Invalid email format. Please provide a valid email address."
    exit 1
fi

print_status "Using email: $USER_EMAIL"

# Create a temporary parameters file with the email replaced
TEMP_PARAMETERS_FILE=$(mktemp)
trap "rm -f $TEMP_PARAMETERS_FILE; cleanup" EXIT

# Replace email placeholder in parameters file
if grep -q "REPLACE_WITH_EMAIL" "$PARAMETERS_FILE"; then
    sed "s/REPLACE_WITH_EMAIL/$USER_EMAIL/g" "$PARAMETERS_FILE" > "$TEMP_PARAMETERS_FILE"
    print_status "Email address updated in parameters."
elif grep -q "your-email@example.com" "$PARAMETERS_FILE"; then
    sed "s/your-email@example.com/$USER_EMAIL/g" "$PARAMETERS_FILE" > "$TEMP_PARAMETERS_FILE"
    print_status "Email address updated in parameters."
else
    # If no placeholder found, just copy the file
    cp "$PARAMETERS_FILE" "$TEMP_PARAMETERS_FILE"
    print_warning "No email placeholder found in parameters file. Using original parameters."
fi

# Use the temporary parameters file for deployment
PARAMETERS_FILE="$TEMP_PARAMETERS_FILE"

print_status "Starting deployment of $STACK_NAME at $(date)..."

# Get template size
TEMPLATE_SIZE=$(stat -c%s "$TEMPLATE_FILE" 2>/dev/null || echo "0")
print_debug "Template size: $(($TEMPLATE_SIZE / 1024))KB"

# Always use S3 for large templates (over 50KB)
if [ "$TEMPLATE_SIZE" -gt 51200 ]; then
    print_warning "Template is large ($(($TEMPLATE_SIZE / 1024))KB). Using S3 for deployment..."
    
    # Create a unique S3 bucket name with timestamp and random suffix
    BUCKET_NAME=$(generate_bucket_name "$S3_BUCKET_PREFIX")
    TEMPLATE_KEY="ai-app-deployer.template"
    
    print_status "Creating S3 bucket: $BUCKET_NAME"
    print_debug "Generated bucket name: $BUCKET_NAME"
    
    # Create S3 bucket with retry logic
    MAX_RETRIES=3
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"; then
            print_status "S3 bucket created successfully: $BUCKET_NAME"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
                print_warning "Failed to create bucket (attempt $RETRY_COUNT/$MAX_RETRIES). Trying with new name..."
                # Generate new bucket name with current timestamp
                BUCKET_NAME=$(generate_bucket_name "$S3_BUCKET_PREFIX")
                print_debug "New bucket name: $BUCKET_NAME"
            else
                print_error "Failed to create S3 bucket after $MAX_RETRIES attempts. The bucket name might already exist or there might be a permissions issue."
                exit 1
            fi
        fi
    done
    
    # Upload template to S3
    print_status "Uploading template to S3..."
    if ! aws s3 cp "$TEMPLATE_FILE" "s3://$BUCKET_NAME/$TEMPLATE_KEY"; then
        print_error "Failed to upload template to S3."
        exit 1
    fi
    
    # Set template URL
    TEMPLATE_URL="https://$BUCKET_NAME.s3.$REGION.amazonaws.com/$TEMPLATE_KEY"
    print_debug "Template URL: $TEMPLATE_URL"
    
    USE_S3=true
else
    print_status "Using direct template body for deployment..."
    USE_S3=false
fi

# Check if stack already exists
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" &> /dev/null; then
    print_warning "Stack '$STACK_NAME' already exists. Updating stack..."
    OPERATION="update-stack"
else
    print_status "Creating new stack '$STACK_NAME'..."
    OPERATION="create-stack"
fi

# Deploy the stack
print_status "Deploying CloudFormation stack..."

# Build the command based on template delivery method
if [ "$USE_S3" = true ]; then
    # Use S3 URL
    aws cloudformation "$OPERATION" \
        --stack-name "$STACK_NAME" \
        --template-url "$TEMPLATE_URL" \
        --parameters "file://$PARAMETERS_FILE" \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --region "$REGION" \
        --cli-read-timeout 0 \
        --cli-connect-timeout 60
else
    # Use direct template body
    aws cloudformation "$OPERATION" \
        --stack-name "$STACK_NAME" \
        --template-body "file://$TEMPLATE_FILE" \
        --parameters "file://$PARAMETERS_FILE" \
        --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --region "$REGION" \
        --cli-read-timeout 0 \
        --cli-connect-timeout 60
fi

if [ $? -eq 0 ]; then
    print_status "Stack deployment initiated successfully!"
    print_status "Waiting for stack operation to complete..."
    
    # Wait for stack operation to complete
    if [ "$OPERATION" = "create-stack" ]; then
        WAIT_OPERATION="stack-create-complete"
    else
        WAIT_OPERATION="stack-update-complete"
    fi
    
    aws cloudformation wait "$WAIT_OPERATION" \
        --stack-name "$STACK_NAME" \
        --region "$REGION"
    
    if [ $? -eq 0 ]; then
        print_status "Stack operation completed successfully!"
        
        # Get stack outputs
        print_status "Retrieving stack outputs..."
        aws cloudformation describe-stacks \
            --stack-name "$STACK_NAME" \
            --region "$REGION" \
            --query 'Stacks[0].Outputs' \
            --output table
    else
        print_error "Stack operation failed. Check the AWS Console for details."
        exit 1
    fi
else
    print_error "Failed to initiate stack deployment."
    exit 1
fi

print_status "Deployment completed!"