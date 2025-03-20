{
  pkgs,
  inputs,
  ...
}:
{
  # 引入 `nvf` (Neovim Flake) 模块
  imports = [ inputs.nvf.nixosModules.default ];
  # 开启 Neovim
  programs.nvf = {
    enable = true;
    enableManpages = true; # 启用 Neovim 的帮助文档

    settings = {
      vim = {
        # 基本 Neovim 配置
        preventJunkFiles = true; # 防止生成临时文件
        searchCase = "smart"; # 智能大小写搜索
        useSystemClipboard = true; # 允许与系统剪贴板共享
        viAlias = true; # 让 `vi` 命令使用 Neovim
        vimAlias = true; # 让 `vim` 命令使用 Neovim
        undoFile.enable = true; # 启用撤销文件，重启后仍可撤销

        options = {
          tabstop = 2;
          shiftwidth = 2;
          wrap = false;
        };

        ### 🔧 LSP（语言服务器）相关配置
        lsp = {
          formatOnSave = false; # 关闭保存时自动格式化
          lspkind.enable = false;
          lightbulb.enable = false;
          lspsaga.enable = false;
          trouble.enable = true; # 启用 LSP 诊断界面
          lspSignature.enable = true; # 显示函数签名
          lsplines.enable = false;
          nvim-docs-view.enable = false;
        };

        ### 🐞 调试器（DAP）
        debugger.nvim-dap = {
          enable = true;
          ui.enable = true;
        };

        ### 🌍 语言支持（LSP + Treesitter + 代码格式化）
        languages = {
          enableLSP = true; # 启用 LSP
          enableFormat = true; # 启用代码格式化
          enableTreesitter = true; # 启用 Treesitter 语法解析
          enableExtraDiagnostics = true; # 启用额外的 LSP 诊断

          nix.enable = true; # Nix 语言支持
          markdown.enable = true; # Markdown 支持
          html.enable = true; # HTML 支持
          css.enable = true; # CSS 支持
          sql.enable = true; # SQL 支持
          java.enable = false; # 关闭 Java 支持
          ts.enable = true; # 启用 TypeScript
          go.enable = true; # 启用 Go 语言支持
          zig.enable = true; # 启用 Zig 语言支持
          python.enable = true; # 启用 Python 语言支持
          lua.enable = true; # 启用 Lua 语言支持
          bash.enable = true; # 启用 Bash 语言支持
          clang = {
            enable = true; # 启用 C/C++ 语言支持
            lsp.server = "clangd"; # 使用 clangd 作为 LSP 服务器
          };
          rust = {
            enable = true; # 启用 Rust 语言支持
            crates.enable = true; # Rust Crates 依赖管理支持
          };
        };

        ### 🎨 视觉增强（UI 相关）
        visuals = {
          nvim-web-devicons.enable = true; # 启用图标支持
          cellular-automaton.enable = true;
          fidget-nvim.enable = true; # 显示 LSP 加载状态
          highlight-undo.enable = true; # 撤销时高亮修改部分
          indent-blankline.enable = true; # 显示缩进参考线
          nvim-cursorline = {
            enable = true;
            setupOpts = {
              lineTimeout = 0;
            };
          };
        };

        ### 📊 状态栏配置
        statusline.lualine = {
          enable = true;
          theme = "tokyonight"; # 使用 Tokyo Night 主题
        };

        ### 🎨 主题配置
        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
          transparent = false; # 关闭透明背景
        };

        autopairs.nvim-autopairs.enable = true; # 启用自动配对插件
        autocomplete.nvim-cmp.enable = true; # 启用智能自动补全插件
        snippets.luasnip.enable = true; # 启用代码片段插件

        tabline = {
          nvimBufferline.enable = true;
        }; # 启用文件标签栏

        treesitter.context.enable = true; # 启用代码上下文提示

        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        }; # 启用快捷键提示和帮助文档

        git = {
          enable = true;
          gitsigns.enable = true;
          gitsigns.codeActions.enable = false; # 禁用 Git 代码操作提示，防止调试信息
        };

        projects.project-nvim.enable = true; # 启用项目管理插件
        dashboard.dashboard-nvim.enable = true; # 启用启动界面插件

        filetree.neo-tree.enable = true; # 启用文件树插件

        notify = {
          nvim-notify.enable = true; # 启用通知插件
        };

        utility = {
          ccc.enable = false; # 禁用颜色选择插件
          vim-wakatime.enable = false; # 禁用 Wakatime 插件
          icon-picker.enable = true; # 启用图标选择插件
          surround.enable = true; # 启用 Surround 插件
          diffview-nvim.enable = true; # 启用 DiffView 插件，用于查看 Git 差异
          motion = {
            hop.enable = true; # 启用 Hop 插件，快速跳转到指定位置
            leap.enable = true; # 启用 Leap 插件，增强跳转功能
            precognition.enable = false; # 禁用 Precognition 插件
          };
          images.image-nvim.enable = false; # 禁用图片插件
        };

        ui = {
          borders.enable = true; # 启用界面边框效果
          noice.enable = true; # 启用高级信息显示插件
          colorizer.enable = true; # 启用颜色高亮插件
          illuminate.enable = true; # 启用光标高亮插件
          breadcrumbs = {
            enable = false;
            navbuddy.enable = false;
          }; # 禁用导航面包屑插件
          smartcolumn = {
            enable = false;
          }; # 禁用智能列宽插件
          fastaction.enable = true; # 启用快速操作插件
        };

        ### 📌 终端集成
        terminal.toggleterm = {
          enable = true;
          lazygit.enable = true;
        };

        ### 📝 记事 & 任务管理
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
                  config = {
                    workspaces = {
                      notes = "~/Documents/neorg";
                    };
                  };
                };
              };
            };
          };
          todo-comments.enable = true; # 启用 TODO 标注
        };

        ### 🎭 代码注释
        comments.comment-nvim.enable = true;

        ### 🔥 额外插件
        lazy.plugins = with pkgs.vimPlugins; {
          ${eyeliner-nvim.pname} = {
            package = eyeliner-nvim;
            event = [ "BufEnter" ];
            after = ''print('hello')'';
          };
          ${lazygit-nvim.pname} = {
            lazy = true;
            cmd = [
              "LazyGit"
              "LazyGitConfig"
              "LazyGitCurrentFile"
              "LazyGitFilter"
              "LazyGitFilterCurrentFile"
            ];
            package = lazygit-nvim;
            setupOpts = {
              open_cmd = "zen %s";
            };
            keys = [
              {
                key = "<leader>lg";
                action = "<cmd>LazyGit<cr>";
                mode = "n";
              }
            ];
          };
        };

        ### ⌨️ 自定义快捷键
        keymaps = [
          {
            key = "<leader><leader>";
            mode = "n";
            action = "<cmd>:Telescope find_files<cr>";
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
