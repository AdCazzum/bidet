# Bidet

```sh
cd zk
nargo build
bb write_vk -b ./target/zk.json -o ./target --oracle_hash keccak
bb write_solidity_verifier -k ./target/vk -o ./target/Verifier.sol
nargo execute witness
bb prove -b ./target/zk.json -w ./target/witness.gz -o ./target --oracle_hash keccak --output_format bytes_and_fields
echo -n "0x"; cat ./target/proof | od -An -v -t x1 | tr -d $' \n'
``
# bidet

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Build bindings for Mopro
Inside ./mopro directory run

## Requirements
- Build the Containerfile with Docker / Podman
- Inside the container shell run the follogin command

```bash
 podman  run  --userns=keep-id --env HOME=/home/<user> -v /home/<user>:/home/<user> -it --rm mopro-cli:latest
```

```bash
ANDROID_NDK_HOME=/home/<user>/Android/Sdk/ndk RUST_BACKTRACE=1 mopro build --platforms android
```