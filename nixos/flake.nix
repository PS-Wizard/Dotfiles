{
    description = "NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        opencode.url = "github:anomalyco/opencode";

        # Zen browser from its dedicated flake.
        zen-browser.url = "github:youwen5/zen-browser-flake";

        # Optional but recommended when following nixos-unstable.
        zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    };

    outputs = { self, nixpkgs, opencode, zen-browser, ... }: {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                {
                    environment.systemPackages = [
                        opencode.packages.x86_64-linux.default
                        zen-browser.packages.x86_64-linux.default
                    ];
                }
            ];
        };
    };
}
