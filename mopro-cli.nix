{ rustPlatform
, # fetchFromGitHub,
  pkgs
, mopro-src
}:
let
  # mopro-src = fetchFromGitHub {
  #   owner = "zkmopro";
  #   repo = "mopro";
  #   hash = pkgs.lib.fakeHash;
  #   rev = "95b81cc56925d15134bb969be31e04d222f9670f";
  # };

in
rustPlatform.buildRustPackage {
  pname = "mopro-cli";
  version = "pippo";
  src = "${mopro-src}/cli";
  cargoLock = {
    lockFile = "${mopro-src}/Cargo.lock";
    outputHashes = {
      "acir-1.0.0-beta.3" = pkgs.lib.fakeHash;
      "bb-0.1.0" = pkgs.lib.fakeHash;
      "fibonacci-circuit-0.1.0" = pkgs.lib.fakeHash;
      "halo2-keccak-256-0.1.0" = pkgs.lib.fakeHash;
      "halo2_proofs-0.2.0" = pkgs.lib.fakeHash;
    };
  };
}
