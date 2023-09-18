{
  description = "Dev shell for charts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      devEnvVars = {
        KUBE_CONFIG_PATH = "~/.kube/config";
        KUBE_CTX = "k3d-k3s-default";
      };
    in
      with pkgs; {
        devShells.default = mkShell (devEnvVars
          // {
            nativeBuildInputs = [
              alejandra
              kubectl
              tilt
              k3d
              vendir
              ytt
              yq-go
              kubernetes-helm
            ];

            shellHook = ''
              alias tf=terraform
              alias k=kubectl
            '';
          });

        formatter = alejandra;
      });
}
