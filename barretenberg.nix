{ overrideCC, stdenv, llvmPackages, cmake, ninja, lib, callPackage, binaryen, gcc11, fetchFromGitHub, tracy, git }:
let
  targetPlatform = stdenv.targetPlatform;
  buildEnv =
    if (stdenv.targetPlatform.isGnu && stdenv.targetPlatform.isAarch64) then
      overrideCC llvmPackages.stdenv (llvmPackages.clang.override { gccForLibs = gcc11.cc; })
    else
      llvmPackages.stdenv;
  optionals = lib.lists.optionals;
  aztec-packages = fetchFromGitHub {
    owner = "AztecProtocol";
    repo = "aztec-packages";
    rev = "594d8bd7b620bbb04c76f8b64869ae0cbe9e5256";
    hash = "sha256-20zooeyixBd+dEBcuE8UOPBruNlbqYkBcVyQ/auvysM=";
  };
  barretenberg = "${aztec-packages}/barretenberg/cpp";
  toolchain_file = "${barretenberg}/cpp/cmake/toolchains/${targetPlatform.system}.cmake";
in
buildEnv.mkDerivation
{
  pname = "libbarretenberg";
  version = "0.1.0";

  src = barretenberg;

  nativeBuildInputs = [ cmake ninja tracy git ]
    ++ optionals targetPlatform.isWasm [ binaryen ];

  buildInputs = [ ]
    ++ optionals (targetPlatform.isDarwin || targetPlatform.isLinux) [
    llvmPackages.openmp
  ];

  env = {
    TRACY_INCLUDE = "${tracy.src}";
  };

  cmakeFlags = [
    "-DTESTING=OFF"
    "-DBENCHMARKS=OFF"
    "-DCMAKE_TOOLCHAIN_FILE=${toolchain_file}"
  ]
  ++ optionals (targetPlatform.isDarwin || targetPlatform.isLinux)
    [ "-DCMAKE_BUILD_TYPE=RelWithAssert" ];

  NIX_CFLAGS_COMPILE =
    optionals targetPlatform.isDarwin [ " -fno-aligned-allocation" ];

  enableParallelBuilding = true;
}
