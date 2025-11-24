#!/bin/bash

# AWS credentials should be set as environment variables before running this script:
# export AWS_ACCESS_KEY_ID="your-access-key"
# export AWS_SECRET_ACCESS_KEY="your-secret-key"
# export AWS_SESSION_TOKEN="your-session-token"  # if using temporary credentials

OUTPUT_DIR="s3_extracted_data"
mkdir -p "$OUTPUT_DIR"

echo "Starting S3 data extraction..."
echo "Output directory: $OUTPUT_DIR"
echo ""

BUCKET_LIST=$(aws s3 ls | awk '{print $3}')
TOTAL_BUCKETS=$(echo "$BUCKET_LIST" | wc -l)
CURRENT=0

echo "Found $TOTAL_BUCKETS buckets"
echo ""

for BUCKET in $BUCKET_LIST; do
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_BUCKETS] Processing bucket: $BUCKET"
    
    BUCKET_DIR="$OUTPUT_DIR/$BUCKET"
    mkdir -p "$BUCKET_DIR"
    
    FILE_COUNT=$(aws s3 ls s3://$BUCKET --recursive 2>/dev/null | wc -l)
    
    if [ $FILE_COUNT -eq 0 ]; then
        echo "  ⚠️  Empty or inaccessible"
    else
        echo "  Found $FILE_COUNT files, downloading..."
        aws s3 sync s3://$BUCKET "$BUCKET_DIR" --quiet 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "  ✅ Downloaded successfully"
        else
            echo "  ❌ Download failed (permissions or error)"
        fi
    fi
    echo ""
done

echo "Extraction complete!"
echo ""
echo "Summary:"
find "$OUTPUT_DIR" -type f | wc -l | xargs echo "Total files extracted:"
du -sh "$OUTPUT_DIR" | awk '{print "Total size: " $1}'
