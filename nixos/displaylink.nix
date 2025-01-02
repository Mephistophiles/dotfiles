{
  linux-override = final: prev: {
    linuxPackages_latest =
      prev.linuxPackages_latest.extend
        (lpfinal: lpprev: {
          evdi =
            lpprev.evdi.overrideAttrs (efinal: eprev: {
              version = "1.12.0-git";
              src = prev.fetchFromGitHub {
                owner = "DisplayLink";
                repo = "evdi";
                rev = "bdc258b25df4d00f222fde0e3c5003bf88ef17b5";
                sha256 = "sha256-mt+vEp9FFf7smmE2PzuH/3EYl7h89RBN1zTVvv2qJ/o=";
              };
            });
        });
    displaylink = prev.displaylink.override {
      inherit (final.linuxPackages_latest) evdi;
    };
  };
}
