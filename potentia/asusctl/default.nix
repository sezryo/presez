{ lib
, fetchFromGitLab
, fetchpatch
, rustPlatform
, pkg-config
, udev
}:
rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.2.1";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-nw4Y5/+pzhRBSiqL8bDSACAYCQeSthPYXunoYiiSi6Y=";
  };
  cargoHash = "sha256-1BGov+xRpRSH3yFjC89PsV1lIVxJfmfcP46UzLJ6eWw=";

  checkType = "debug";
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  '';
}
