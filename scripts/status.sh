#!/usr/bin/env bash

cat << EOF
----------------------------------------------- Script version 0.1.7 ---------------------------------------------
	service name		service status			local node block height
------------------------------------------------------------------------------------------------------------------
	khala-node			stop				 / 1342196
	kusama-node			stop				 / 11701311
	phala-pruntime			stop
	phala-pherry			stop				khala  / kusama
------------------------------------------------------------------------------------------------------------------
	Status check							result
------------------------------------------------------------------------------------------------------------------
	khala chain synchronization status		Synchronizing, please wait, difference is 10359115
	kusama chain synchronization status		Synchronization completed, difference is
	pherry synchronizes khala chain status		Synchronization completed, difference is
	pherry syncs kusama chain status  		Synchronization completed, difference is
------------------------------------------------------------------------------------------------------------------
	account information		content
------------------------------------------------------------------------------------------------------------------
	node name           		zert-test
	cores     			1
	GAS account address      	41MdjXzYn4vKBNPPywXTgugLscUygPb3VNHACNqe52HQNvjg
	GAS account balance      	10PHA
	stake pool account address	41MdjXzYn4vKBNPPywXTgugLscUygPb3VNHACNqe52HQNvjg
	miner/worker public key 	Waiting for the miner to register
	miner registration status	Not registered, please wait for the synchronization to complete
	miner score
------------------------------------------------------------------------------------------------------------------
Please wait for the miner registration status to change to registered before proceeding on-chain operations
If the chain synchronization is completed, but the pherry height is empty, please enter the group and ask
----------------------  Remaining 16s refresh   --------------------------
------------------------------------------------------------------------------------------------------------------
EOF