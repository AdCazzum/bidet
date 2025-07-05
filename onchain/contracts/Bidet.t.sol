// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Bidet } from "./Bidet.sol";
/* import { HonkVerifier } from "./Verifier.sol"; */
import {Groth16Verifier} from "verifier.sol";
import { Test } from "forge-std/Test.sol";

// Solidity tests are compatible
// use the same syntax and offer the same functionality.

contract BidetTest is Test {
    /* Bidet bidet; */
    /* HonkVerifier verifier; */
                           
    function setUp() public {
        /* bidet = new Bidet(); */
        verifier = new Groth16Verifier();
    }
  
  function test_ProofVerification() public {
      

      require(verifier.verifyProof(
        [  "13697072795148118532214718360039267658168080617511508494202291611842465924833",
           "19683049145503697843194827807524635329849370057121309029840814476328144558285"],

        [[
         "13744688196551963241622691745386154016447312318587475762698900772295170860724",
         "21489653858354765213231995597616753987492600232265886583538722222083938765295"],
         ["20100474226347100279780624300209553423844134475285587338778725606297480853455",
         "4848319062086083222189917651802561683905313790005884021995794318834937856621"
        ]],
        
        [
         "6843090959430066262488502743685226234692169624035246097705314165482349024361",
         "19077609673582227202662630232066080564353441354728659909762280923573282418693"
        ],
        ["19014214495641488759237505126948346942972912379615652741039992445865937985820"]
      ), "Proof not valid");
  }
}
