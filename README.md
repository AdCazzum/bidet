# Bidet

**bidet** is a real-world mobile game where players catch each other and generate **Zero Knowledge Proofs** (ZKPs) to prove that a specific player has been caught — without revealing who it was.

ZK proofs are generated directly on the catcher's phone using **Circom** and **Mopro**, and then verified on-chain by a smart contract deployed on a **Saga** chainlet.

---

## Overview

- 🧠 Proofs are generated locally on mobile using `mopro`.
- 🔒 The identity of the caught player is never revealed.
- ⛓️ Proofs are submitted to an on-chain verifier (Groth16 verifier contract).
- ✅ The contract checks validity without learning any private data.

---

## Tech Stack

- **Circom** – ZK circuit language
- **Mopro** – Mobile-friendly zkSNARK prover
- **snarkjs** – Setup and proof tooling
- **Solidity** – On-chain Groth16 verifier
- **Saga chainlet** – Blockchain deployment target

---

## Dev notes

```bash
 podman  run  --userns=keep-id --env HOME=/home/<user> -v /home/<user>:/home/<user> -it --rm mopro-cli:latest
```

```bash
ANDROID_NDK_HOME=/home/<user>/Android/Sdk/ndk RUST_BACKTRACE=1 mopro build --platforms android
```

https://bidet-2751756364524000-1.sagaexplorer.io/address/0x6400442155A9bB3521438503AC658523566Bf073?tab=contract
