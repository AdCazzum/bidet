// Here we're calling a macro exported with Uniffi. This macro will
// write some functions and bind them to FFI type.
// These functions include:
// - `generate_circom_proof`
// - `verify_circom_proof`
// - `generate_halo2_proof`
// - `verify_halo2_proof`
// - `generate_noir_proof`
// - `verify_noir_proof`
mopro_ffi::app!();

// Activate rust-witness function
rust_witness::witness!(multiplier2);

// Set the witness functions to a zkey
mopro_ffi::set_circom_circuits! {
    ("multiplier2_final.zkey", mopro_ffi::witness::WitnessFn::RustWitness(multiplier2_witness)),
}

#[cfg(test)]
mod circom_tests {
    use super::*;

    #[test]
    fn test_multiplier2() {
        let zkey_path = "./test-vectors/circom/multiplier2_final.zkey".to_string();
        let circuit_inputs = "{\"a\": 2, \"b\": 3}".to_string();
        let result = generate_circom_proof(zkey_path.clone(), circuit_inputs, ProofLib::Arkworks);
        assert!(result.is_ok());
        let proof = result.unwrap();
        let valid = verify_circom_proof(zkey_path, proof, ProofLib::Arkworks);
        assert!(valid.is_ok());
        assert!(valid.unwrap());
    }
}
