{ pkgs, lib, config, ... }:
{
  programs.vscode = {
    enable = true;
    userSettings = {
      "[nix]" = {
        "editor.tabSize" = 2;
        "editor.formatOnSaveMode" = "file";
      };

      "clangd.arguments" = [
        "--background-index"
        "--compile-commands-dir=build"
        "-j=20"
        "--clang-tidy"
      ];
      "cmake.configureOnOpen" = false;
      "diffEditor.codeLens" = true;
      "diffEditor.ignoreTrimWhitespace" = false;
      "editor.cursorBlinking" = "smooth";
      "editor.fontFamily" = "'FiraCode Nerd Font Mono', 'Microsoft Yahei', Monaco, 'Courier New', monospace";
      "editor.fontLigatures" = true;
      "editor.formatOnSave" = true;
      "editor.formatOnSaveMode" = "modifications";
      "editor.inlineSuggest.enabled" = true;
      "editor.lineNumbers" = "relative";
      "editor.rulers" = [
        80
      ];
      "editor.suggestSelection" = "first";
      "editor.tokenColorCustomizations" = {
        textMateRules = [
          {
            name = "Comment";
            scope = [
              "comment"
              "comment.block"
              "comment.block.documentation"
              "comment.line"
              "comment.line.double-slash"
              "punctuation.definition.comment"
            ];
            settings = {
              fontStyle = "";
            };
          }
        ];
      };
      "editor.unicodeHighlight.allowedCharacters" = {
        "\uff08" = true;
        "\uff09" = true;
        "\uff0c" = true;
      };
      "files.exclude" = {
        "**/.classpath" = true;
        "**/.factorypath" = true;
        "**/.project" = true;
        "**/.settings" = true;
      };
      "files.autoSave" = "onFocusChange";
      "files.insertFinalNewline" = true;
      "files.trimTrailingWhitespace" = true;
      "git.autofetch" = true;
      "git.enableCommitSigning" = true;
      "git.mergeEditor" = false;
      "latex-workshop.latex.autoBuild.run" = "onSave";
      "latex-workshop.latex.recipe.default" = "XeLaTeXmk";
      "latex-workshop.latex.recipes" = [
        {
          name = "XeLaTeXmk";
          tools = [
            "XeLaTeXmk"
          ];
        }
        {
          name = "pdfLaTeXmk";
          tools = [
            "pdfLaTeXmk"
          ];
        }
        {
          name = "LuaLaTeXmk";
          tools = [
            "LuaLaTeXmk"
          ];
        }
        {
          name = "LaTeXmk-DVIPDFMx";
          tools = [
            "LaTeXmk-DVIPDFMx"
          ];
        }
        {
          name = "upLaTeXmk-DVIPDFMx";
          tools = [
            "upLaTeXmk-DVIPDFMx"
          ];
        }
      ];
      "latex-workshop.latex.tools" = [
        {
          args = [
            "-xelatex"
            "-synctex=1"
            "-shell-escape"
            "-interaction=nonstopmode"
            "-file-line-error"
            "%DOC%"
          ];
          command = "latexmk";
          name = "XeLaTeXmk";
        }
        {
          args = [
            "-pdflatex"
            "-synctex=1"
            "-shell-escape"
            "-interaction=nonstopmode"
            "-file-line-error"
            "%DOC%"
          ];
          command = "latexmk";
          name = "pdfLaTeXmk";
        }
        {
          args = [
            "-lualatex"
            "-synctex=1"
            "-shell-escape"
            "-interaction=nonstopmode"
            "-file-line-error"
            "%DOC%"
          ];
          command = "latexmk";
          name = "LuaLaTeXmk";
        }
        {
          args = [
            "-e"
            "$dvipdf='dvipdfmx %O -o %D %S'"
            "-latex"
            "-pdfdvi"
            "-synctex=1"
            "-shell-escape"
            "-interaction=nonstopmode"
            "-file-line-error"
            "%DOC%"
          ];
          command = "latexmk";
          name = "LaTeXmk-DVIPDFMx";
        }
        {
          args = [
            "-e"
            "$dvipdf='dvipdfmx %O -o %D %S'"
            "-latex=uplatex"
            "-pdfdvi"
            "-synctex=1"
            "-shell-escape"
            "-interaction=nonstopmode"
            "-file-line-error"
            "%DOC%"
          ];
          command = "latexmk";
          name = "upLaTeXmk-DVIPDFMx";
        }
      ];
      "latex-workshop.view.pdf.viewer" = "tab";
      "nix.serverPath" = "rnix-lsp";
      "nix.enableLanguageServer" = true;
      "python.analysis.typeCheckingMode" = "basic";
      "python.languageServer" = "Pylance";
      "python.terminal.activateEnvironment" = false;
      "remote.SSH.enableRemoteCommand" = true;
      "rust-analyzer.checkOnSave.command" = "clippy";
      "settingsSync.ignoredExtensions" = [
        "asvetliakov.vscode-neovim"
        "github.copilot"
        "vscjava.vscode-java-debug"
      ];
      "settingsSync.ignoredSettings" = [
        "editor.fontSize"
        "vscode-neovim.neovimExecutablePaths.linux"
        "vscode-neovim.neovimExecutablePaths.darwin"
      ];
      "telemetry.telemetryLevel" = "off";
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.integrated.defaultProfile.osx" = "zsh";
      "terminal.integrated.fontFamily" = "\"MesloLGS NF\", 'FiraCode Nerd Font Mono', \"Consolas\", \"Microsoft Yahei\"";
      "terminal.integrated.profiles.linux" = {
        bash = {
          icon = "terminal-bash";
          path = "bash";
        };
        fish = {
          path = "fish";
        };
        pwsh = {
          icon = "terminal-powershell";
          path = "pwsh";
        };
        tmux = {
          icon = "terminal-tmux";
          path = "tmux";
        };
        zsh = {
          args = [
            "-l"
          ];
          path = "zsh";
        };
      };
      "terminal.integrated.profiles.osx" = {
        bash = {
          args = [
            "-l"
          ];
          icon = "terminal-bash";
          path = "bash";
        };
        fish = {
          args = [
            "-l"
          ];
          path = "fish";
        };
        pwsh = {
          icon = "terminal-powershell";
          path = "pwsh";
        };
        tmux = {
          icon = "terminal-tmux";
          path = "tmux";
        };
        zsh = {
          args = [
            "-l"
          ];
          path = "/opt/homebrew/bin/zsh";
        };
      };
      "vscode-neovim.neovimExecutablePaths.linux" = "/run/current-system/sw/bin/nvim";
      "vscode-neovim.useCtrlKeysForInsertMode" = false;
      "window.menuBarVisibility" = "toggle";
      "workbench.colorTheme" = "Nord";
      "workbench.editor.untitled.hint" = "hidden";
      "workbench.editorAssociations" = {
        "*.md" = "default";
        "git-rebase-todo" = "default";
      };
      "vscode-neovim.neovimExecutablePaths.darwin" = "/opt/homebrew/bin/nvim";
      "editor.fontSize" = 14;
      "window.zoomLevel" = -1;
    };
    extensions = with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
      llvm-vs-code-extensions.vscode-clangd
      jnoortheen.nix-ide
      eamodio.gitlens
      mhutchie.git-graph
      asvetliakov.vscode-neovim
      arcticicestudio.nord-visual-studio-code
      usernamehw.errorlens
      james-yu.latex-workshop
      shardulm94.trailing-spaces
    ];
  };
}
