#!/bin/bash
echo "Authenticating with GitHub Container Registry using gh CLI..."
gh auth token | docker login ghcr.io -u $(gh api user --jq .login) --password-stdin
