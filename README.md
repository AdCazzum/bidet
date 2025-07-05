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
