{ lib, rustPlatform, fetchFromGitLab, pkg-config, udev, kmod }:

rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "3.0.0";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-ozQfXvR1Z9j9SGtQyZapik8B/UvT96crHsFiNL/hjgk=";
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
  cargoHash = "sha256-C4E9WnWzSKR2RCUbCjPL2wmEbSlg4C+Ouw1OhtH5GSE=";
  
  makeFlags = [ "prefix=${placeholder "out"}" ];
  buildPhase = "buildPhase";
  installPhase = "installPhase";
}
