{
  pkgs,
  inputs,
  ...
}:
{
  # 引入 `nvf` (Neovim Flake) 模块
  imports = [ inputs.nvf.nixosModules.default ];

  programs.nvf = {
    enable = true;
    enableManpages = true;

    settings = {
      vim = {
        ## ======================
        ## 基本配置
        ## ======================
        preventJunkFiles = true;
        searchCase = "smart";
        viAlias = true;
        vimAlias = true;

        undoFile.enable = true;

        options = {
          tabstop = 2;
          shiftwidth = 2;
          wrap = false;
        };

        ## ======================
        ## 剪贴板（替代 useSystemClipboard）
        ## ======================
	clipboard = {
  enable = true;
  registers = "unnamedplus";
};

        ## ======================
        ## LSP
        ## ======================
        lsp = {
          formatOnSave = false;
          lspkind.enable = false;
          lightbulb.enable = false;
          lspsaga.enable = false;
          trouble.enable = true;
          lspSignature.enable = true;
          nvim-docs-view.enable = false;
        };

        ## 替代 lsplines（保持你原来“关闭”的语义）
        diagnostics.config = {
          virtual_lines = false;
        };

        ## ======================
        ## DAP
        ## ======================
        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        ## ======================
        ## 语言支持
        ## ======================
        languages = {
          enableLSP = true;
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;

          nix.enable = true;
          markdown.enable = true;
          html.enable = true;
          css.enable = true;
          sql.enable = true;
          java.enable = false;
          ts.enable = true;
          go.enable = true;
          zig.enable = true;
          python.enable = true;
          lua.enable = true;
          bash.enable = true;

          clang = {
            enable = true;
            lsp.server = "clangd";
          };

          rust = {
            enable = true;
            crates.enable = true;
          };
        };

        ## ======================
        ## 视觉/UI
        ## ======================
        visuals = {
          nvim-web-devicons.enable = true;
          cellular-automaton.enable = true;
          fidget-nvim.enable = true;
          highlight-undo.enable = true;
          indent-blankline.enable = true;

          nvim-cursorline = {
            enable = true;
            setupOpts = {
              lineTimeout = 0;
            };
          };
        };

        ## ======================
        ## 状态栏 / 主题
        ## ======================
        statusline.lualine = {
          enable = true;
          theme = "tokyonight";
        };

        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
          transparent = false;
        };

        ## ======================
        ## 编辑增强
        ## ======================
        autopairs.nvim-autopairs.enable = true;
        autocomplete.nvim-cmp.enable = true;
        snippets.luasnip.enable = true;

        tabline.nvimBufferline.enable = true;
        treesitter.context.enable = true;

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        ## ======================
        ## Git
        ## ======================
        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false;
        };

        ## ======================
        ## 项目 / 文件
        ## ======================
        projects.project-nvim.enable = true;
        dashboard.dashboard-nvim.enable = true;
        filetree.neo-tree.enable = true;

        ## ======================
        ## 通知 / UI
        ## ======================
        notify.nvim-notify.enable = true;

        utility = {
          ccc.enable = false;
          vim-wakatime.enable = false;
          icon-picker.enable = true;
          surround.enable = true;
          diffview-nvim.enable = true;

          motion = {
            hop.enable = true;
            leap.enable = true;
            precognition.enable = false;
          };

          images.image-nvim.enable = false;
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
          colorizer.enable = true;
          illuminate.enable = true;

          breadcrumbs = {
            enable = false;
            navbuddy.enable = false;
          };

          smartcolumn.enable = false;
          fastaction.enable = true;
        };

        ## ======================
        ## 终端
        ## ======================
        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };

        ## ======================
        ## 笔记 / 注释
        ## ======================
        notes = {
          neorg = {
            enable = true;
            setupOpts = {
              load = {
                "core.defaults" = { };
                "core.concealer" = { };
                "core.completion" = {
                  config.engine = "nvim-cmp";
                };
                "core.export" = { };
                "core.summary" = { };
                "core.text-objects" = { };
                "core.dirman" = {
                  config.workspaces.notes = "~/Documents/neorg";
                };
              };
            };
          };

          todo-comments.enable = true;
        };

        comments.comment-nvim.enable = true;

        ## ======================
        ## Lazy 插件
        ## ======================
        lazy.plugins = with pkgs.vimPlugins; {
          ${eyeliner-nvim.pname} = {
            package = eyeliner-nvim;
            event = [ "BufEnter" ];
            after = ''print("hello")'';
          };

          ${lazygit-nvim.pname} = {
            lazy = true;
            package = lazygit-nvim;
            cmd = [
              "LazyGit"
              "LazyGitConfig"
              "LazyGitCurrentFile"
              "LazyGitFilter"
              "LazyGitFilterCurrentFile"
            ];
            setupOpts.open_cmd = "zen %s";
            keys = [
              {
                key = "<leader>lg";
                action = "<cmd>LazyGit<cr>";
                mode = "n";
              }
            ];
          };
        };

        ## ======================
        ## 快捷键
        ## ======================
        keymaps = [
          {
            key = "<leader><leader>";
            mode = "n";
            action = "<cmd>Telescope find_files<cr>";
            silent = true;
            desc = "快速查找文件";
          }
          {
            key = "<leader>fe";
            mode = "n";
            action = "<cmd>Neotree toggle<cr>";
            desc = "neo-tree";
          }
        ];
      };
    };
  };
}

