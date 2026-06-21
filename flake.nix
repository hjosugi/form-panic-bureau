{
  description = "Form Panic Elm browser game environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      formPanicPackages = pkgs: [
        pkgs.elmPackages.elm
        pkgs.elmPackages.elm-format
        pkgs.elmPackages.elm-language-server
        pkgs.elmPackages.elm-test
        pkgs.nixd
        pkgs.nixfmt
        pkgs.nodejs_22
      ];

      formPanicApp =
        pkgs: name: command:
        let
          script = pkgs.writeShellApplication {
            name = "form-panic-${name}";
            runtimeInputs = formPanicPackages pkgs;
            text = command;
          };
        in
        {
          type = "app";
          program = "${script}/bin/form-panic-${name}";
          meta.description = "Form Panic ${name} command";
        };
    in
    {
      apps = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          app = formPanicApp pkgs;
        in
        {
          default = app "dev" "npm run dev";
          build = app "build" "npm run build";
          check = app "check" "npm run check";
          dev = app "dev" "npm run dev";
          start = app "start" "npm start";
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = formPanicPackages pkgs;

            shellHook = ''
              echo "Form Panic dev shell"
              echo "  node  $(node --version)"
              echo "  npm   $(npm --version)"
              echo "  elm   $(elm --version)"
              echo "  elm-format        $(command -v elm-format)"
              echo "  elm-test          $(command -v elm-test)"
              echo "  elm-language-server $(command -v elm-language-server)"
              echo "  nixd              $(command -v nixd)"
              echo "  nixfmt            $(command -v nixfmt)"
            '';
          };
        }
      );

      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.writeShellApplication {
          name = "form-panic-fmt";
          runtimeInputs = [ pkgs.nixfmt ];
          text = "nixfmt flake.nix";
        }
      );
    };
}
