#!/bin/bash

set -e

echo "🔄 Starting S3 data sync..."

# Configuration
OUTPUT_DIR="/workspaces/empty-base-repo/s3_extracted_data"
ROLE_ARN="${AWS_ROLE_ARN:-}"
SESSION_NAME="gitpod-s3-sync-$(date +%s)"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI not found, installing..."
    curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    unzip -q /tmp/awscliv2.zip -d /tmp
    sudo /tmp/aws/install
    rm -rf /tmp/aws /tmp/awscliv2.zip
    echo "✅ AWS CLI installed"
fi

# Assume role if ROLE_ARN is provided
if [ -n "$ROLE_ARN" ]; then
    echo "🔐 Assuming IAM role: $ROLE_ARN"
    
    CREDENTIALS=$(aws sts assume-role \
        --role-arn "$ROLE_ARN" \
        --role-session-name "$SESSION_NAME" \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
        --output text)
    
    if [ $? -eq 0 ]; then
        export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | awk '{print $1}')
        export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | awk '{print $2}')
        export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | awk '{print $3}')
        echo "✅ Role assumed successfully"
    else
        echo "❌ Failed to assume role"
        exit 1
    fi
else
    echo "ℹ️  Using existing AWS credentials (no role assumption)"
fi

# Verify AWS credentials work
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured or invalid"
    echo ""
    echo "To configure:"
    echo "1. Set AWS_ROLE_ARN environment variable in devcontainer.json, OR"
    echo "2. Set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN"
    exit 1
fi

echo "✅ AWS credentials validated"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Get bucket list
BUCKET_LIST=$(aws s3 ls | awk '{print $3}')
TOTAL_BUCKETS=$(echo "$BUCKET_LIST" | wc -l)
CURRENT=0
SUCCESS_COUNT=0
FAIL_COUNT=0

echo "📦 Found $TOTAL_BUCKETS buckets"
echo ""

# Sync each bucket
for BUCKET in $BUCKET_LIST; do
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_BUCKETS] Syncing: $BUCKET"
    
    BUCKET_DIR="$OUTPUT_DIR/$BUCKET"
    mkdir -p "$BUCKET_DIR"
    
    # Check if bucket has files
    FILE_COUNT=$(aws s3 ls s3://$BUCKET --recursive 2>/dev/null | wc -l)
    
    if [ $FILE_COUNT -eq 0 ]; then
        echo "  ⚠️  Empty or inaccessible"
    else
        # Sync bucket (only download new/changed files)
        if aws s3 sync s3://$BUCKET "$BUCKET_DIR" --quiet 2>/dev/null; then
            echo "  ✅ Synced ($FILE_COUNT files)"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        else
            echo "  ❌ Sync failed"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ S3 sync complete!"
echo ""
echo "Summary:"
echo "  • Buckets synced: $SUCCESS_COUNT"
echo "  • Failed: $FAIL_COUNT"
echo "  • Total files: $(find "$OUTPUT_DIR" -type f 2>/dev/null | wc -l)"
echo "  • Total size: $(du -sh "$OUTPUT_DIR" 2>/dev/null | awk '{print $1}')"
echo "  • Location: $OUTPUT_DIR"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
