{
  description = "T3 Code desktop app and CLI, from the official release binaries";
  homepage = "https://github.com/pingdotgg/t3code";

  # `yo update t3code` rewrites release.json for the latest stable release.
  update = {
    type = "github-release";
    repo = "pingdotgg/t3code";
    file = "release.json";
    assets = {
      x86_64-linux = {
        # AppImage file names no longer carry the version in newer releases.
        desktop = [ "T3-Code-x86_64.AppImage" "T3-Code-{version}-x86_64.AppImage" ];
        cli = [ "t3-{version}-linux-x64.tar.gz" ];
      };
      aarch64-linux = {
        desktop = [ "T3-Code-arm64.AppImage" "T3-Code-{version}-arm64.AppImage" ];
        cli = [ "t3-{version}-linux-arm64.tar.gz" ];
      };
    };
  };
}
