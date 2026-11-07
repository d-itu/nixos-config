{ pkgs, ... }: {
  xdg.dataFile."nvim/site/pack/nix".source = pkgs.papervim + /share/nvim/site/pack/nix;
  programs = {
    neovim = {
      enable = true;
      extraPackages = with pkgs; [
        clang-tools
        fish-lsp
        lua-language-server
        nixd
        tinymist
        ty
        typescript-language-server
        vscode-json-languageserver
        vscode-html-languageserver
        vscode-css-languageserver
        yaml-language-server
        zls
      ];
      plugins = with pkgs.vimPlugins; [
        {
          plugin = nvim-lspconfig;
          optional = true;
        }
        {
          plugin = nvim-treesitter.withPlugins (
            plugins: with plugins; [
              bash
              c
              caddy
              cmake
              cpp
              css
              desktop
              diff
              dtd
              fish
              git_config
              gitcommit
              glsl
              html
              ini
              javascript
              json
              kdl
              kitty
              kotlin
              llvm
              lua
              luadoc
              make
              markdown
              markdown_inline
              meson
              nix
              objdump
              odin
              proto
              python
              regex
              rust
              scss
              ssh_config
              toml
              typescript
              typst
              vim
              xml
              yaml
              zig
              zsh
              (pkgs.tree-sitter.buildGrammar {
                language = "nisba";
                version = "0.1.0";
                src = pkgs.fetchFromGitHub {
                  owner = "nisba-dev";
                  repo = "tree-sitter-nisba";
                  rev = "d156511baca5d6b55f224b57910470736b9e9d70";
                  hash = "sha256-/q793gAqWKrU7VSzIbFlNsKXT1fhoNr7czqefPWHIss=";
                };
                generate = true;
                preInstall = ''
                  rm -rf queries
                  cp -r nvim/queries queries
                '';
              })
              (pkgs.tree-sitter.buildGrammar {
                language = "wgsl";
                version = "0.1.0";
                src = pkgs.fetchFromGitHub {
                  owner = "d-itu";
                  repo = "tree-sitter-wgsl";
                  rev = "d4cd4083364036a4067a94da8522055c1ce6eb5f";
                  hash = "sha256-jhHlbzaJnCpnBf5ua06GNOF9bknMTyUhdIisT/xQa54=";
                };
                generate = true;
                preInstall = ''
                  rm -rf queries
                  cp -r nvim/queries queries
                '';
              })
            ]
          );
          optional = true;
        }
      ];
    };
    neovide = {
      enable = true;
    };
  };
}
