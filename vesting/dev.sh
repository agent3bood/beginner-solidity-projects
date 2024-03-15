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

echo "Deploying Token..."
TOKEN_DEPLOY_OUTPUT=$(forge script DeployToken --fork-url http://localhost:8545 --broadcast --unlocked --sender $SENDER_ADDRESS)

echo "Deploying Vester..."
VESTER_DEPLOY_OUTPUT=$(forge script DeployVester --fork-url http://localhost:8545 --broadcast --unlocked --sender $SENDER_ADDRESS)

jq '.abi' out/Token.sol/Token.json > app/src/abi/Token.json
jq '.abi' out/Vester.sol/Vester.json > app/src/abi/Vester.json

TOKEN_ADDRESS=$(echo "$TOKEN_DEPLOY_OUTPUT" | awk '/Contract Address:/{print $3}')
VESTER_ADDRESS=$(echo "$VESTER_DEPLOY_OUTPUT" | awk '/Contract Address:/{print $3}')

echo "REACT_APP_TOKEN_ADDRESS=$TOKEN_ADDRESS" > app/.env
echo "REACT_APP_VESTER_ADDRESS=$VESTER_ADDRESS" >> app/.env

echo "Press Ctrl-C to exit"
while true; do
    sleep 1
done
