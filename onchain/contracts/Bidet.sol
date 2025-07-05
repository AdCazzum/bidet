// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {HonkVerifier} from "./Verifier.sol";
import "hardhat/console.sol";


contract Bidet {
    HonkVerifier public immutable verifier;
    
    function test(bytes calldata proof, bytes32 hash) public returns(bool) {
      bytes32[] memory publicInputs = new bytes32[](1);
      publicInputs[0] = hash;
      console.log("here");
      require(verifier.verify(proof, publicInputs), "Invalid proof");
  }
}
