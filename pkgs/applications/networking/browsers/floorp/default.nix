{ stdenv
, lib
, fetchFromGitHub
, buildMozillaMach
, nixosTests
, python311
}:

((buildMozillaMach rec {
  pname = "floorp";
  packageVersion = "11.16.0";
  applicationName = "Floorp";
  binaryName = "floorp";
  branding = "browser/branding/official";
  requireSigning = false;
  allowAddonSideload = true;

  # Must match the contents of `browser/config/version.txt` in the source tree
  version = "115.15.0";

  src = fetchFromGitHub {
    owner = "Floorp-Projects";
    repo = "Floorp";
    fetchSubmodules = true;
    rev = "v${packageVersion}";
    hash = "sha256-bmB88EIc5S/EYZXiQ5Dc+LjcGB4dlwKRBBV0T0ln88E=";
  };

  extraConfigureFlags = [
    "--with-app-name=${pname}"
    "--with-app-basename=${applicationName}"
    "--with-unsigned-addon-scopes=app,system"
  ];

  extraPostPatch = ''
    # Fix .desktop files for PWAs generated by Floorp
    # The executable path returned by Services.dirsvc.get() is absolute and
    # thus is the full /nix/store/[..] path. To avoid breaking PWAs with each
    # update, rely on `floorp` being in $PATH, as before.
    substituteInPlace floorp/browser/base/content/modules/ssb/LinuxSupport.mjs \
      --replace-fail 'Services.dirsvc.get("XREExeF",Ci.nsIFile).path' '"floorp"'
  '';

  updateScript = ./update.sh;

  meta = {
    description = "A fork of Firefox, focused on keeping the Open, Private and Sustainable Web alive, built in Japan";
    homepage = "https://floorp.app/";
    maintainers = with lib.maintainers; [ christoph-heiss ];
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    broken = stdenv.buildPlatform.is32bit; # since Firefox 60, build on 32-bit platforms fails with "out of memory".
                                           # not in `badPlatforms` because cross-compilation on 64-bit machine might work.
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    license = lib.licenses.mpl20;
    mainProgram = "floorp";
  };
  tests = [ nixosTests.floorp ];
}).override {
  # Upstream build configuration can be found at
  # .github/workflows/src/linux/shared/mozconfig_linux_base
  privacySupport = true;
  webrtcSupport = true;
  enableOfficialBranding = false;
  googleAPISupport = true;
  mlsAPISupport = true;
  python3 = python311;
}).overrideAttrs (prev: {
  MOZ_DATA_REPORTING = "";
  MOZ_TELEMETRY_REPORTING = "";
})
