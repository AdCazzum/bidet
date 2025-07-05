#!/bin/sh

circom $1.circom --r1cs --wasm --sym --c
npx snarkjs powersoftau new bn128 12 pot12_0000.ptau -v
npx snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
npx snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
npx snarkjs groth16 setup $1.r1cs pot12_final.ptau $1_0000.zkey
npx snarkjs zkey export verificationkey $1_0000.zkey verification_key.json
npx snarkjs zkey export solidityverifier $1_0000.zkey verifier.sol

