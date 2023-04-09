self: super:

assert super.unstable.neovim-unwrapped.version == "0.8.3";
let
  tree-sitter = super.unstable.tree-sitter.overrideAttrs (old: rec {
    version = "0.20.8";
    sha256 = "sha256-278zU5CLNOwphGBUa4cGwjBqRJ87dhHMzFirZB09gYM=";
    src = super.fetchFromGitHub {
      owner = "tree-sitter";
      repo = "tree-sitter";
      rev = "v0.20.8";
      sha256 = "sha256-278zU5CLNOwphGBUa4cGwjBqRJ87dhHMzFirZB09gYM=";
      fetchSubmodules = true;
    };
    cargoDeps = old.cargoDeps.overrideAttrs (super.lib.const {
      name = "tree-sitter-vendor.tar.gz";
      inherit src;
      outputHash = "sha256-fr4usZ0Vc65eKjaAA2KVEIW3t5jDgefIIFwqpilmj7g=";
    });
  });
  neovim-unwrapped = super.unstable.neovim-unwrapped.overrideAttrs
    (old: {
      src = super.fetchFromGitHub {
        owner = "neovim";
        repo = "neovim";
        rev = "v0.9.0";
        hash = "sha256-4uCPWnjSMU7ac6Q3LT+Em8lVk1MuSegxHMLGQRtFqAs=";
      };
      version = "0.9.0";
      patches = [ (super.lib.elemAt old.patches 0) ];
      buildInputs = (super.lib.filter (package: !(super.lib.strings.hasPrefix "tree-sitter-" package.name)) old.buildInputs) ++ [ tree-sitter ];
    });
in
{
  neovim-unwrapped = neovim-unwrapped;
  neovim = super.wrapNeovim neovim-unwrapped { };
}
