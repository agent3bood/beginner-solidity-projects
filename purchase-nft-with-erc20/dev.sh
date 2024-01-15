#!/bin/bash

cleanup() {
    echo "SIGINT received, exiting..."
    kill $ANVIL_PID
    exit 0
}

anvil &
ANVIL_PID=$!

sleep 5

SENDER_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

echo "Deploying GLDToken..."
GLDTOKEN_DEPLOY_OUTPUT=$(forge script DeployGLDToken --fork-url http://localhost:8545 --broadcast --unlocked --sender $SENDER_ADDRESS)

echo "Deploying GLDNFT..."
GLDNFT_DEPLOY_OUTPUT=$(forge script DeployGLDNFT --fork-url http://localhost:8545 --broadcast --unlocked --sender $SENDER_ADDRESS)

jq '.abi' out/Token.sol/GLDToken.json > app/src/abi/GLDToken.json
jq '.abi' out/NFT.sol/GLDNFT.json > app/src/abi/GLDNFT.json

GLDTOKEN_ADDRESS=$(echo "$GLDTOKEN_DEPLOY_OUTPUT" | awk '/Contract Address:/{print $3}')
GLDNFT_ADDRESS=$(echo "$GLDNFT_DEPLOY_OUTPUT" | awk '/Contract Address:/{print $3}')

echo "REACT_APP_TOKEN_ADDRESS=$GLDTOKEN_ADDRESS" > app/.env
echo "REACT_APP_NFT_ADDRESS=$GLDNFT_ADDRESS" >> app/.env

echo "Press Ctrl-C to exit"
while true; do
    sleep 1
done
