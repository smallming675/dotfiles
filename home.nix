{
  inputs,
  pkgs,
  config,
  nix4nvchad,
  lib,
  ...
}: let
  colors = {
    fg = "#c0caf5";
    bg = "#1a1b26";
    black = "#15161e";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    cyan = "#7dcfff";
    white = "#c0caf5";
    orange = "#ff9e64";

    bright0 = "#414868";
    bright1 = "#ff899d";
    bright2 = "#9fe044";
    bright3 = "#faba4a";
    bright4 = "#8db0ff";
    bright5 = "#c7a9ff";
    bright6 = "#a4daff";
    bright7 = "#c0caf5";
  };
  # uid = "1000";
in {
  imports = [
    nix4nvchad.homeManagerModule
  ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSymlinkPath = "${config.home.homeDirectory}/.local/share/sops-nix/secrets";
    defaultSecretsMountPoint = "${config.home.homeDirectory}/.local/share/sops-nix/secrets.d";
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_STYLE_OVERRIDE = "";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    NVD_BACKEND = "direct";
    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Bibata-Modern-Black";
    XCOMPOSEFILE = "~/.XCompose";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Black";
    size = 24;
  };

  home.packages = with pkgs; [
    (pass.withExtensions (exts: [exts.pass-otp]))
    mullvad-vpn

    # CLI
    ripgrep
    fd
    bat
    eza
    fzf
    btop
    grc
    jq
    delta
    zoxide
    atuin
    hyfetch
    zip
    unzip
    unrar
    wl-clipboard
    rip2
    watchexec

    # Dev tools
    git
    github-cli
    neovim
    (python3.withPackages (ps: []))
    cargo
    rustc
    rust-analyzer
    alejandra
    nodejs
    gcc
    gnumake
    cmake
    gdb
    valgrind
    cppcheck
    ctags
    bear
    uv
    jdk
    ghostscript
    imagemagick
    graphviz
    gemini-cli-bin
    lazygit

    # GUI
    grim
    slurp
    hyprpicker
    libsixel
    chafa
    pamixer
    brightnessctl
    playerctl

    # Wayland
    swaybg
    hyprpaper
    pavucontrol
    bibata-cursors

    # Media
    yt-dlp
    mpv
    ffmpeg
    kew
    gimp
    zathura
    libreoffice

    # Others
    usbmuxd
    localsend
    syncthing
    obsidian
    docker
    nautilus
    kitty
    foot
  ];

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      format = ''$directory$python$git_branch$character'';
      right_format = "";
      add_newline = false;
      line_break.disabled = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      python = {
        symbol = " ";
        format = ''[$symbol$pyenv_prefix$virtualenv]($style) '';
      };
      sudo = {
        format = "[$symbol]($style) ";
        style = "bold yellow";
        symbol = " ";
        disabled = false;
      };
      cmd_duration.disabled = true;
      hostname = {
        ssh_only = false;
        format = "[$hostname](bold red) ";
        disabled = true;
      };
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch(:$remote_branch)]($style) ";
        style = "blue";
      };
      directory = {
        format = "[$read_only]($read_only_style)[$path]($style) ";
        read_only = " ";
        truncation_length = 4;
        home_symbol = "~";
        style = "green";
      };
    };
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
      {
        name = "fzf";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
    shellInit = ''
      set fish_greeting
      eval "$(zoxide init fish)"
      function bind_bang
        switch (commandline -t)[-1]
          case "!"
            commandline -t -- $history[1]
            commandline -f repaint
          case "*"
            commandline -i !
        end
      end
      function starship_transient_prompt_func
        starship module character
      end

      starship init fish | source
      atuin init fish | source
      function fish_user_key_bindings
        if command -s fzf-share >/dev/null
          source (fzf-share)/key-bindings.fish
        end
        bind ! bind_bang
        fzf_key_bindings
      end
      enable_transience

      set -gx UV_PYTHON $VIRTUAL_ENV/bin/python

    '';
    interactiveShellInit = ''
      alias cd="z"
      alias cls="clear"
      alias cal="qalc"
      alias copy="wl-copy"
      alias ls="exa --icons=auto"
      alias la="exa --icons=auto"
      alias lt="exa --tree --level=3 --icons=auto"
      alias cat="bat"
      alias rm="rip"
      alias ..="cd ../"
      alias ...="cd ../../"
      alias ....="cd ../../../"
      alias .....="cd ../../../../"
      alias py="python"
      alias nv="nvim"
      alias cp="rsync"
      if not set -q TMUX
        exec tmux new-session -A -s main
      end

      set -g fish_key_bindings fish_vi_key_bindings
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_replace_one underscore
      set -g fish_cursor_visual block
    '';
  };

  programs.nvchad = {
    enable = true;
    hm-activation = true;
    backup = false;
    extraPackages = with pkgs; [
      nodePackages.typescript-language-server
      lua-language-server
      rust-analyzer
      nixfmt
      clang-tools
      (python3.withPackages (ps: with ps; [pyright flake8]))
    ];
    extraPlugins = ''
      return {
        {
          "neovim/nvim-lspconfig",
          config = function()
            require("nvchad.configs.lspconfig").defaults()
            local servers = {
              "html", "cssls", "rust-analyzer", "clangd",
              "pyright", "eslint-lsp", "lua-language-server", "nixfmt" }
            vim.lsp.enable(servers)
          end,
        },
        {
            "kylechui/nvim-surround",
            version = "^3.0.0", -- Use for stability; omit to use `main` branch for the latest features
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        }
      };
    '';
    extraConfig = ''
      local map = vim.keymap.set
      vim.o.wrap = false
      vim.o.relativenumber = true
      map("n", ";", ":", { desc = "CMD enter command mode" })
      map({ "n", "v" }, "J", "<C-d>", { desc = "Go Down" })
      map({ "n", "v" }, "K", "<C-u>", { desc = "Go Up" })
      map("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      map("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    '';
    chadrcConfig = ''
      local M = {}
      M.base46 = {
        theme = "tokyonight",
        transparency = false,
      }
      return M
    '';
  };

  programs.git = {
    enable = true;
    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "SmallMing675";
        email = "181466198+smallming675@users.noreply.github.com";
      };
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta.navigate = true;
      merge.conflictstyle = "diff3";
      merge.tool = "nvimdiff";
      gui.editor = "nvim";
      color.ui = "auto";
      pull.rebase = false;
      push.autoSetupRemote = true;
      gpg.format = "ssh";
      commit.gpgsign = true;
    };
  };

  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    mouse = true;
    baseIndex = 1;
    prefix = "C-b";
    escapeTime = 0;

    plugins = with pkgs; [
    ];

    extraConfig = ''
      set-option -g status-position top
      set -g status-interval 1
      set -g status-style "bg=${colors.bg},fg=${colors.fg}"
      set -g status-left-length 50
      set -g status-left ""
      set -g window-status-format "#[fg=${colors.blue},bg=${colors.bg}] #I "
      set -g window-status-current-format "#[fg=${colors.yellow},bg=${colors.black},bold] #I "
      set -g window-status-separator " "
      set -g status-right-length 100
      set -g status-right "#[fg=${colors.bright0}] %d %b %Y %H:%M "
      set -g pane-border-style "fg=${colors.black}"
      set -g pane-active-border-style "fg=${colors.blue}"
      set -s extended-keys on
      set -as terminal-features 'xterm*:extkeys'

      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      bind -n C-+ resize-pane -U 5
      bind -n C-_ resize-pane -D 5


      bind -n C-t new-window -c "#{pane_current_path}"
      bind -n C-w kill-pane

      bind h split-window -hb
      bind l split-window -h
      bind k split-window -vb
      bind j split-window -v

      bind -n C-a select-window -t 1
      bind -n C-s select-window -t 2
      bind -n C-d select-window -t 3
      bind -n C-f select-window -t 4

      bind -n M-a select-window -t 5
      bind -n M-s select-window -t 6
      bind -n M-d select-window -t 7
      bind -n M-f select-window -t 8
    '';
  };

  programs.alacritty = {
    enable = true;
    settings = {
      terminal = {
        shell = "fish";
      };
      window = {
        padding = {
          x = 6;
          y = 6;
        };
        opacity = 1.0;
      };

      font = {
        size = 18;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "SemiBold";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
      };

      colors = {
        primary = {
          background = colors.bg;
          foreground = colors.fg;
        };

        cursor = {
          text = colors.bg;
          cursor = colors.fg;
        };

        normal = {
          black = colors.black;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.magenta;
          cyan = colors.cyan;
          white = colors.white;
        };

        bright = {
          black = colors.bright0;
          red = colors.bright1;
          green = colors.bright2;
          yellow = colors.bright3;
          blue = colors.bright4;
          magenta = colors.bright5;
          cyan = colors.bright6;
          white = colors.bright7;
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    settings = {
      layerrule = [
        "no_anim on, match:namespace rofi"
      ];
      xwayland.force_zero_scaling = true;
      monitor = ", preferred, auto, 1";
      exec-once = [
        "swaybg -c ${lib.removePrefix "#" colors.bg}"
        "[workspace 1 silent] brave"
        "[workspace 2 silent] alacritty"
        "[workspace 3 silent] obsidian"
        "[workspace 4 silent] vesktop"
      ];
      input = {
        follow_mouse = 0;
        touchpad = {
          natural_scroll = true;
          tap_to_click = true;
          tap_and_drag = true;
        };
      };
      misc = {
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        vfr = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
        anr_missed_pings = 3;
      };
      cursor = {
        no_hardware_cursors = true;
        hide_on_key_press = true;
      };
      general = {
        border_size = 0;
        resize_on_border = false;
        allow_tearing = false;
        gaps_in = 0;
        gaps_out = 0;
      };
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 2, easeOutQuint"
        ];
      };
      master.new_status = "master";
      ecosystem.no_update_news = true;
      debug.disable_logs = false;
      bind = [
        "SUPER,T,exec,alacritty"
        "SUPER,N,exec,brave"
        "SUPER,M,fullscreen"
        "SUPER,P,togglefloating"
        "SUPER,Q,killactive"
        "SUPER,U,exec, slurp | grim -g - - | wl-copy"
        "SUPER,SUPER_L,exec,rofi -show drun || pkill rofi"
        "SUPER SHIFT,S,exec,hyprpicker -a"
        "SUPER,O,exec,obsidian"
        "SUPER,Tab,cyclenext"
        "SUPER,6,workspace,1"
        "SUPER,7,workspace,2"
        "SUPER,8,workspace,3"
        "SUPER,9,workspace,4"
        "SUPER,1,workspace,5"
        "SUPER,2,workspace,6"
        "SUPER,3,workspace,7"
        "SUPER,4,workspace,8"
        "SUPER CTRL,h,movetoworkspace,1"
        "SUPER CTRL,j,movetoworkspace,2"
        "SUPER CTRL,k,movetoworkspace,3"
        "SUPER CTRL,l,movetoworkspace,4"
        "SUPER CTRL,a,movetoworkspace,5"
        "SUPER CTRL,s,movetoworkspace,6"
        "SUPER CTRL,d,movetoworkspace,7"
        "SUPER CTRL,f,movetoworkspace,8"
        "SUPER ALT,h,movewindow,l"
        "SUPER ALT,j,movewindow,d"
        "SUPER ALT,k,movewindow,u"
        "SUPER ALT,l,movewindow,r"
        "SUPER SHIFT,l,resizeactive,100 0"
        "SUPER SHIFT,h,resizeactive,-100 0"
        "SUPER SHIFT,k,resizeactive,0 -100"
        "SUPER SHIFT,j,resizeactive,0 100"
        ",XF86AudioRaiseVolume,exec,pamixer -ui 5"
        ",XF86AudioLowerVolume,exec,pamixer -ud 5"
        ",XF86AudioMute,exec,pamixer --toggle-mute"
        ",XF86MonBrightnessUp,exec,brightnessctl set 10%+"
        ",XF86MonBrightnessDown,exec,brightnessctl set 10%-"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPrev,exec,playerctl previous"
        "SUPER,mouse:272,movewindow"
        "SUPER,grave,togglespecialworkspace"
        "SUPER ALT,grave,movetoworkspace,special"
      ];
      bindr = [
        "SUPER,h,movefocus,l"
        "SUPER,l,movefocus,r"
        "SUPER,k,movefocus,u"
        "SUPER,j,movefocus,d"
      ];
    };
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    commandLineArgs = ["--force-device-scale-factor=1.3"];
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      vim_keys = true;
      update_ms = 100;
      proc_sorting = "name";
      show_gpu_info = "Auto";
      graph_symbol_gpu = "default";
      nvml_measure_pcie_speeds = true;
      rsmi_measure_pcie_speeds = true;
      gpu_mirror_graph = true;
      shown_gpus = "nvidia amd intel";
    };
  };

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 16";
    terminal = "alacritty";
    extraConfig = {
      show-icons = false;
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " Files";
      display-window = " Windows";
      display-ssh = " SSH";
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      case-sensitive = false;
      matching = "normal";
      sort = true;
      click-to-exit = true;
      parse-hosts = true;
      parse-known-hosts = true;
      ssh-client = "ssh";
      ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
      cycle = true;
    };

    theme = builtins.toFile "theme.rasi" ''
      * {
          background:                  ${colors.black}FF;
          background-alt:              ${colors.bg}FF;
          foreground:                  ${colors.fg}FF;
          selected:                    ${colors.fg}FF;
          active:                      ${colors.cyan}FF;
          urgent:                      ${colors.red}FF;
          border-colour:               transparent;
          handle-colour:               var(selected);
          background-colour:           var(background);
          foreground-colour:           var(foreground);
          alternate-background:        var(background-alt);
          normal-background:           var(background);
          normal-foreground:           var(foreground);
          urgent-background:           var(urgent);
          urgent-foreground:           var(background);
          active-background:           var(active);
          active-foreground:           var(background);
          selected-normal-background:  var(selected);
          selected-normal-foreground:  var(background);
          selected-urgent-background:  var(active);
          selected-urgent-foreground:  var(background);
          selected-active-background:  var(urgent);
          selected-active-foreground:  var(background);
          alternate-normal-background: var(background);
          alternate-normal-foreground: var(foreground);
          alternate-urgent-background: var(urgent);
          alternate-urgent-foreground: var(background);
          alternate-active-background: var(active);
          alternate-active-foreground: var(background);
      }

      window {
          location:                    center;
          anchor:                      center;
          fullscreen:                  false;
          width:                       800px;
          x-offset:                    0px;
          y-offset:                    0px;
          enabled:                     true;
          margin:                      12px;
          padding:                     0px;
          border-radius:               0px 0px 12px 12px;
          border:                      0px solid;
          cursor:                      "default";
          background-color:            @background-colour;
      }

      mainbox {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     20px;
          border:                      0px solid;
          border-radius:               0px 0px 0px 0px;
          background-color:            @background-colour;
          children:                    [ "inputbar", "message", "custombox" ];
      }

      custombox {
          spacing:                     10px;
          background-color:            @background-colour;
          text-color:                  @foreground-colour;
          orientation:                 horizontal;
          children:                    [ "mode-switcher", "listview" ];
      }

      inputbar {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     8px 12px;
          border:                      0px solid;
          border-radius:               8px;
          border-color:                @border-colour;
          background-color:            @alternate-background;
          text-color:                  @foreground-colour;
          children:                    [ "textbox-prompt-colon", "entry" ];
      }

      prompt {
          enabled:                     true;
          background-color:            inherit;
          text-color:                  inherit;
      }

      textbox-prompt-colon {
          enabled:                     true;
          padding:                     5px 0px;
          expand:                      false;
          str:                         "";
          background-color:            inherit;
          text-color:                  inherit;
      }

      entry {
          enabled:                     true;
          padding:                     5px 0px;
          background-color:            inherit;
          text-color:                  inherit;
          cursor:                      text;
          placeholder:                 "Search...";
          placeholder-color:           inherit;
      }

      num-filtered-rows {
          enabled:                     true;
          expand:                      false;
          background-color:            inherit;
          text-color:                  inherit;
      }

      textbox-num-sep {
          enabled:                     true;
          expand:                      false;
          str:                         "/";
          background-color:            inherit;
          text-color:                  inherit;
      }

      num-rows {
          enabled:                     true;
          expand:                      false;
          background-color:            inherit;
          text-color:                  inherit;
      }

      case-indicator {
          enabled:                     true;
          background-color:            inherit;
          text-color:                  inherit;
      }

      listview {
          enabled:                     true;
          columns:                     1;
          lines:                       8;
          cycle:                       true;
          dynamic:                     true;
          scrollbar:                   true;
          layout:                      vertical;
          reverse:                     false;
          fixed-height:                true;
          fixed-columns:               true;
          spacing:                     5px;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
          cursor:                      "default";
      }

      scrollbar {
          handle-width:                5px ;
          handle-color:                @handle-colour;
          border-radius:               10px;
          background-color:            @alternate-background;
      }

      element {
          enabled:                     true;
          spacing:                     10px;
          margin:                      0px;
          padding:                     10px;
          border:                      0px solid;
          border-radius:               8px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
          cursor:                      pointer;
      }

      element normal.normal {
          background-color:            var(normal-background);
          text-color:                  var(normal-foreground);
      }
      element normal.urgent {
          background-color:            var(urgent-background);
          text-color:                  var(urgent-foreground);
      }
      element normal.active {
          background-color:            var(active-background);
          text-color:                  var(active-foreground);
      }
      element selected.normal {
          background-color:            var(selected-normal-background);
          text-color:                  var(selected-normal-foreground);
      }
      element selected.urgent {
          background-color:            var(selected-urgent-background);
          text-color:                  var(selected-urgent-foreground);
      }
      element selected.active {
          background-color:            var(selected-active-background);
          text-color:                  var(selected-active-foreground);
      }
      element alternate.normal {
          background-color:            var(alternate-normal-background);
          text-color:                  var(alternate-normal-foreground);
      }
      element alternate.urgent {
          background-color:            var(alternate-urgent-background);
          text-color:                  var(alternate-urgent-foreground);
      }
      element alternate.active {
          background-color:            var(alternate-active-background);
          text-color:                  var(alternate-active-foreground);
      }
      element-icon {
          background-color:            transparent;
          text-color:                  inherit;
          size:                        24px;
          cursor:                      inherit;
      }
      element-text {
          background-color:            transparent;
          text-color:                  inherit;
          highlight:                   inherit;
          cursor:                      inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
      }

      mode-switcher{
          enabled:                     true;
          expand:                      false;
          orientation:                 vertical;
          spacing:                     10px;
          margin:                      0px;
          padding:                     0px 0px;
          border:                      0px solid;
          border-radius:               0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
      }
      button {
          padding:                     0px 20px 0px 20px;
          border:                      0px solid;
          border-radius:               8px;
          border-color:                @border-colour;
          background-color:            @alternate-background;
          text-color:                  inherit;
          vertical-align:              0.5;
          horizontal-align:            0.0;
          cursor:                      pointer;
      }
      button selected {
          background-color:            var(selected-normal-background);
          text-color:                  var(selected-normal-foreground);
      }

      message {
          enabled:                     true;
          margin:                      0px;
          padding:                     0px;
          border:                      0px solid;
          border-radius:               0px 0px 0px 0px;
          border-color:                @border-colour;
          background-color:            transparent;
          text-color:                  @foreground-colour;
      }
      textbox {
          padding:                     12px;
          border:                      0px solid;
          border-radius:               8px;
          border-color:                @border-colour;
          background-color:            @alternate-background;
          text-color:                  @foreground-colour;
          vertical-align:              0.5;
          horizontal-align:            0.0;
          highlight:                   none;
          placeholder-color:           @foreground-colour;
          blink:                       true;
          markup:                      true;
      }
      error-message {
          padding:                     10px;
          border:                      2px solid;
          border-radius:               8px;
          border-color:                @border-colour;
          background-color:            @background-colour;
          text-color:                  @foreground-colour;
      }
    '';
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
    };
  };

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
  };

  sops.secrets."opencode/base_url" = {};
  sops.secrets."opencode/api_key" = {};

  programs.opencode = {
    enable = true;
    settings = {
      theme = "tokyonight";
      provider = {
        openai = {
          options = {
            baseURL = "{file:${config.sops.secrets."opencode/base_url".path}}";
            apiKey = "{file:${config.sops.secrets."opencode/api_key".path}}";
          };
        };
      };
      autoupdate = true;
      model = "gpt-5-codex";
    };
  };

  xdg.desktopEntries.kew-player = {
    name = "Kew";
    genericName = "Music Player";
    exec = "alacritty --class kew-music -e kew all";
    terminal = false;
    categories = ["Audio" "AudioVideo" "Player"];
  };

  home.stateVersion = "25.11";
}
