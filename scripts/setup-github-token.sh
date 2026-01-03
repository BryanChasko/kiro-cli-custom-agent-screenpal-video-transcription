#!/bin/bash

# Setup GitHub token securely using GitHub CLI or AWS Parameter Store

set -e

echo "🔐 Setting up secure GitHub token access..."

# Option 1: Use GitHub CLI (recommended for local development)
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    echo "✅ GitHub CLI authenticated"
    echo "Using GitHub CLI for token access"
    
    # Create wrapper script that uses gh auth token
    cat > scripts/docker-auth-secure.sh << 'EOF'
#!/bin/bash
echo "Authenticating with GitHub Container Registry using gh CLI..."
gh auth token | docker login ghcr.io -u $(gh api user --jq .login) --password-stdin
EOF
    chmod +x scripts/docker-auth-secure.sh
    echo "✅ Created scripts/docker-auth-secure.sh"
    
# Option 2: Use AWS Parameter Store
elif command -v aws &> /dev/null && aws sts get-caller-identity &> /dev/null 2>&1; then
    echo "✅ AWS CLI authenticated"
    echo "Setting up AWS Parameter Store for token storage"
    
    # Store token in Parameter Store (you'll need to run this once)
    echo "To store your GitHub token in AWS Parameter Store, run:"
    echo "aws ssm put-parameter --name '/github/container-registry-token' --value 'YOUR_TOKEN_HERE' --type 'SecureString'"
    
    # Create wrapper script that uses AWS Parameter Store
    cat > scripts/docker-auth-secure.sh << 'EOF'
#!/bin/bash
echo "Authenticating with GitHub Container Registry using AWS Parameter Store..."
TOKEN=$(aws ssm get-parameter --name '/github/container-registry-token' --with-decryption --query 'Parameter.Value' --output text)
echo "$TOKEN" | docker login ghcr.io -u bryanchasko --password-stdin
EOF
    chmod +x scripts/docker-auth-secure.sh
    echo "✅ Created scripts/docker-auth-secure.sh"
    
else
    echo "❌ Neither GitHub CLI nor AWS CLI is authenticated"
    echo "Please run one of:"
    echo "  gh auth login"
    echo "  aws configure"
    exit 1
fi

echo "🎉 Secure token setup complete!"
echo "Use scripts/docker-auth-secure.sh instead of scripts/docker-auth-pull.sh"
