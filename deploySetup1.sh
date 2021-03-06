#!/bin/bash

DELAY=10

export ARCH=`uname -m`

docker-compose -f docker-compose-pc1.yml up -d

sleep $DELAY

docker network create --attachable --driver overlay asclepeion-net
docker network connect asclepeion-net peer0.org1.example.com
docker network connect asclepeion-net peer3.org1.example.com
docker network connect asclepeion-net  couchdb
docker network connect asclepeion-net  couchdb3
docker network connect asclepeion-net ca.org1.example.com
docker network connect asclepeion-net orderer.example.com

docker exec peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c mychannel -f /etc/hyperledger/configtx/channel.tx

# Join peer0.org1.example.com to the channel.
docker exec -e "CORE_PEER_ADDRESS=peer0.org1.example.com:7051" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block
docker exec -e "CORE_PEER_ADDRESS=peer1.org1.example.com:7051" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block

#Do this after peers join on the network
docker exec -e "CORE_PEER_ADDRESS=peer2.org1.example.com:7051" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block
docker exec -e "CORE_PEER_ADDRESS=peer3.org1.example.com:7051" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b mychannel.block
