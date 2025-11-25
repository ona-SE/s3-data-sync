#!/bin/bash

# This script assumes the S3AccessDemo role and exports credentials
# It's sourced by shell profiles to make AWS credentials available in all sessions

ROLE_ARN="${ONAS3SYNCDEMO_ROLE_ARN:-}"
SESSION_NAME="gitpod-shell-$$"

# Only assume role if ROLE_ARN is provided
if [ -n "$ROLE_ARN" ]; then
    # Use project-specific credentials to assume role
    TEMP_ACCESS_KEY="${ONAS3SYNCDEMO_ACCESS_KEY_ID}"
    TEMP_SECRET_KEY="${ONAS3SYNCDEMO_SECRET_ACCESS_KEY}"
    
    if [ -n "$TEMP_ACCESS_KEY" ] && [ -n "$TEMP_SECRET_KEY" ]; then
        # Assume role and export credentials
        CREDENTIALS=$(AWS_ACCESS_KEY_ID="$TEMP_ACCESS_KEY" \
                      AWS_SECRET_ACCESS_KEY="$TEMP_SECRET_KEY" \
                      aws sts assume-role \
                          --role-arn "$ROLE_ARN" \
                          --role-session-name "$SESSION_NAME" \
                          --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
                          --output text 2>/dev/null)
        
        if [ $? -eq 0 ] && [ -n "$CREDENTIALS" ]; then
            export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | awk '{print $1}')
            export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | awk '{print $2}')
            export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | awk '{print $3}')
        fi
    fi
fi
