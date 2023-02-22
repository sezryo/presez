{ lib
, stdenv
, fetchFromGitLab
, cmake
, e2fsprogs
, fontconfig
, libGL
, libglvnd
, pkg-config
, rustPlatform
, udev
, xorg
, xwayland
, systemd
}:

rustPlatform.buildRustPackage rec {
  pname = "asusctl";
  version = "4.5.0";
  src = fetchFromGitLab {
    owner = "asus-linux";
    repo = pname;
    rev = version;
    sha256 = "sha256-hkNVgMugTllDqnanVU1rdb7viRG4U1f588rLA55yCbY=";
  };
  cargoHash = "sha256-0hPY1+ZlJZfqnWZ+GX1IkhsjU0J0CjrRkegA1DD2yC4=";

  checkType = "debug";
  doCheck = false;

  nativeBuildInputs = [ pkg-config cmake ];
  buildInputs = [
    udev
    fontconfig
    xwayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    e2fsprogs
    libGL
    libglvnd
    systemd
  ];

  postInstall = ''
    make install INSTALL_PROGRAM=true DESTDIR=$out prefix=
  '';
}
