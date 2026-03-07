{
    description = "NixOS configuration";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        zen-browser.url = "github:youwen5/zen-browser-flake";
        zen-browser.inputs.nixpkgs.follows = "nixpkgs";
        opencode.url = "github:anomalyco/opencode";
    };
    outputs = { self, nixpkgs, zen-browser, opencode, ... }: {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                ./configuration.nix
                {
                    environment.systemPackages = [
                        zen-browser.packages.x86_64-linux.default
                        opencode.packages.x86_64-linux.default
                    ];
                }
            ];
        };
    };
}
