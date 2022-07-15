{ lib
, fetchFromGitLab
, fetchpatch
, rustPlatform
, pkg-config
, udev
}:
rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.1.0";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-opRi7v2ZnJq0hOV/4k9tFwxyipf8amCP1gEz20/mPmk=";
  };
  cargoHash = "sha256-JbcGwuXEGSGx7FPbZE7dYJg9M0scvTfQwS7TiFCYglc=";

  checkType = "debug";
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  '';
}
