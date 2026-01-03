#!/bin/bash

# Store GitHub token in AWS Parameter Store securely
# Usage: ./scripts/store-github-token-aws.sh YOUR_GITHUB_TOKEN

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <github_token>"
    echo "Example: $0 ghp_xxxxxxxxxxxxxxxxxxxx"
    exit 1
fi

TOKEN="$1"
PARAMETER_NAME="/github/container-registry-token"

echo "🔐 Storing GitHub token in AWS Parameter Store..."

aws ssm put-parameter \
    --name "$PARAMETER_NAME" \
    --value "$TOKEN" \
    --type "SecureString" \
    --description "GitHub Container Registry token for Docker authentication" \
    --overwrite

echo "✅ Token stored securely in AWS Parameter Store: $PARAMETER_NAME"
echo "🔒 Token is encrypted using AWS KMS"
echo ""
echo "To use this token, run: ./scripts/docker-auth-secure.sh"
