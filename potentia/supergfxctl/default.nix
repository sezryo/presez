{ lib, rustPlatform, fetchFromGitLab, pkg-config, udev, kmod }:

rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "git-715716";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = "715716cfd924dc2105b377d3f4cc437593f47fc6";
    sha256 = "sha256-hdHZ1GNhEotyOOPW3PJMe4+sdTqwic7iCnVsA5a1F1c=";
  };
  patches = [
    ./no-config-write.patch
  ];

  postPatch = ''
    substituteInPlace data/supergfxd.service \
      --replace /usr/bin $out/bin
    substituteInPlace src/controller.rs \
      --replace \"modprobe\" \"${kmod}/bin/modprobe\" \
      --replace \"rmmod\" \"${kmod}/bin/rmmod\"
  ''; 
  
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];
  cargoHash = "sha256-XDpbMjB9q2Jnuq6ru416F66mX2RWeQpXkQjGO1/Wpd8=";
  
  makeFlags = [ "prefix=${placeholder "out"}" ];
  buildPhase = "buildPhase";
  installPhase = "installPhase";
}
