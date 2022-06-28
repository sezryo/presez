{ lib
, fetchFromGitLab
, fetchpatch
, rustPlatform
, pkg-config
, udev
}:
rustPlatform.buildRustPackage rec {
  pname = "supergfxctl";
  version = "git-de0f82";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = "de0f8219c245708d472f4a77dcb4ddd574060a9e";
    sha256 = "sha256-hdHZ1GNhEotyOOPW3PJMe4+sdTqwic7iCnVsA5a1F1c=";
  };
  cargoHash = "sha256-B4HmHFcbPvNlZt7h6vCJFoGBCLveqrU/iUqhbjjks+w=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  ''; 
}
