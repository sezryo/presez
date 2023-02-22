{ lib
, fetchFromGitLab
, fetchpatch
, rustPlatform
, pkg-config
, udev
}:
rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.3.4";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-L1h47yaSiyrpRrJ3E/un7ywpo82VLVsoiJaAoeRBJug=";
  };
  cargoHash = "sha256-KcOviI/HD9nCZpCc2TcSHXGZy3Tm301cLYE38DRzoVs=";

  checkType = "debug";
  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ udev ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  '';
}
