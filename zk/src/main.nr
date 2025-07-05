fn main(bracelet_pk: [u8; 32], bracelet_hash: pub [u8; 32]) {
    let hash = std::hash::blake3(bracelet_pk);
    assert(hash == bracelet_hash);
}