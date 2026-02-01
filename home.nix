{
  pkgs,
  config,
  nix4nvchad,
  ...
}: let
  colors = rec {
    fg = "cdc0ad";
    bg = "252221";
    black = "2b2827";
    red = "c65f5f";
    green = "8ca589";
    yellow = "d9b27c";
    blue = "7d92a2";
    magenta = "998396";
    cyan = "829e9b";
    white = "cdc0ad";
    orange = "d08b65";

    bright0 = "4d4a49";
    bright1 = "dc7575";
    bright2 = "95ae92";
    bright3 = "e1ba84";
    bright4 = "728797";
    bright5 = "d16a6a";
    bright6 = "749689";
    bright7 = "c8baa4";

    hex = {
      fg = "#${fg}";
      bg = "#${bg}";
      black = "#${black}";
      red = "#${red}";
      green = "#${green}";
      yellow = "#${yellow}";
      blue = "#${blue}";
      magenta = "#${magenta}";
      cyan = "#${cyan}";
      white = "#${white}";
      orange = "#${orange}";
    };
  };
in {
  imports = [nix4nvchad.homeManagerModule];

  home.username = "user";
  home.homeDirectory = "/home/user";

  home.packages = with pkgs; [
    (pass.withExtensions (exts: [exts.pass-otp]))
    ripgrep
    fd
    bat
    eza
    fzf
    rip2
    btop
    atuin
    fastfetch
    grc
    usbmuxd
    zip
    unzip
    unrar
    wl-clipboard
    grim
    slurp
    swaybg
    hyprpaper
    pavucontrol
    brightnessctl
    bibata-cursors
    git
    zoxide
    neovim
    (python3.withPackages (ps: [ps.pip]))
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
    ghostscript
    imagemagick
    graphviz
    watchexec
    obsidian
    localsend
    syncthing
    gemini-cli-bin
    ghostty
    hyprpicker
    gimp
    zathura
    delta
    mullvad-vpn
    pamixer
    jq
    libsixel
    chafa
    yt-dlp
    mpv
    ffmpeg
    kew
    jdk
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
        format = ''[$symbol$pyenv_prefix$virtualenv]($style)'';
      };
      sudo = {
        format = "[$symbol]($style)";
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

  programs.bash = {
    enable = true;
    initExtra = ''
      export GEMINI_API_KEY="$(pass show gemini/api-key)"
      export GOOGLE_GEMINI_BASE_URL="$(pass show gemini/base-url)"
    '';
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
      set -g fish_key_bindings fish_vi_key_bindings
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
        theme = "chocolate",
        transparency = false,
      }
      return M
    '';
  };

  programs.git = {
    enable = true;
    signing = {
      key = "/home/user/.ssh/id_ed25519.pub";
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

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    attachExistingSession = true;
    settings = {
      default_shell = "fish";
      default_layout = "default";
      pane_frames = false;
      simplified_ui = false;
      theme = "everblush";
      show_startup_tips = false;
      hide_frame_for_single_pane = true;
      serialize_pane_viewport = true;
      themes = {
        everblush = with colors; {
          fg = hex.fg;
          bg = hex.bg;
          black = hex.black;
          red = hex.red;
          green = hex.green;
          yellow = hex.yellow;
          blue = hex.blue;
          magenta = hex.magenta;
          cyan = hex.cyan;
          white = hex.white;
          orange = hex.orange;
        };
      };
    };
    extraConfig = ''
      keybinds clear-defaults=true {
        shared_except "locked" {
          bind "Ctrl +" { Resize "Increase"; }
          bind "Ctrl -" { Resize "Decrease"; }
          bind "Ctrl a" { GoToTab 1; }
          bind "Ctrl s" { GoToTab 2; }
          bind "Ctrl d" { GoToTab 3; }
          bind "Ctrl f" { GoToTab 4; }
          bind "Ctrl g" { GoToTab 5; }
          bind "Ctrl H" { NewPane "left"; }
          bind "Ctrl J" { NewPane "down"; }
          bind "Ctrl K" { NewPane "up"; }
          bind "Ctrl L" { NewPane "right"; }
          bind "Ctrl h" { MoveFocus "left"; }
          bind "Ctrl j" { MoveFocus "down"; }
          bind "Ctrl k" { MoveFocus "up"; }
          bind "Ctrl l" { MoveFocus "right"; }
          bind "Ctrl t" { NewTab; }
          bind "Ctrl w" { CloseFocus; }
          bind "Alt s" { EditScrollback; }
          bind "Ctrl Alt s" { session-manager; }
        }
      }
    '';
    layouts.default = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            plugin location="file:~/config/bin/zjstatus.wasm" {
              format_left   "{tabs}"
              format_right  "{datetime}"
              format_space  ""
              format_hide_on_overlength "true"
              format_precedence "crl"
              border_enabled  "false"
              border_char     "─"
              border_format   "#[fg=${colors.hex.white}]{char}"
              border_position "top"
              datetime        "#[fg=${colors.hex.white}] {format} "
              datetime_format "%d %b %Y %H:%M"
              datetime_timezone "Hongkong"
              tab_normal  "#[bg=${colors.hex.bg},fg=${colors.hex.blue}] {index} "
              tab_active  "#[bg=${colors.hex.black},fg=${colors.hex.yellow},bold] {index} "
              tab_separator " "
            }
          }
          children
        }
      }
    '';
  };

  programs.foot = {
    enable = true;
    settings = with colors; {
      main = {
        font = "JetBrainsMono Nerd Font:size=18:style=Semibold";
        pad = "6x6 center";
        shell = "fish";
      };
      tweak = {
        sixel = "yes";
      };
      cursor = {
        style = "underline";
        color = "${fg} ${fg}";
      };
      colors = {
        background = bg;
        foreground = fg;
        regular0 = black;
        regular1 = red;
        regular2 = green;
        regular3 = yellow;
        regular4 = blue;
        regular5 = magenta;
        regular6 = cyan;
        regular7 = white;
        bright0 = bright0;
        bright1 = bright1;
        bright2 = bright2;
        bright3 = bright3;
        bright4 = bright4;
        bright5 = bright5;
        bright6 = bright6;
        bright7 = bright7;
      };
      mouse = {
        hide-when-typing = "yes";
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
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "HYPRCURSOR_THEME,Bibata-Modern-Black"
        "XCOMPOSEFILE,~/.XCompose"
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "NVD_BACKEND,direct"
        "GDK_BACKEND,wayland,x11,*"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_STYLE_OVERRIDE,kvantum"
        "SDL_VIDEODRIVER,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        "OZONE_PLATFORM,wayland"
        "XDG_SESSION_TYPE,wayland"
        "XDG_CURRENT_DESKTOP,Hyprland"
        "XDG_SESSION_DESKTOP,Hyprland"
      ];
      xwayland.force_zero_scaling = true;
      monitor = ["DP-1, 2560x1440@180, auto, 1"];
      exec-once = [
        "swaybg -c 201e1d"
        "[workspace 1 silent] brave"
        "[workspace 2 silent] foot"
        "[workspace 3 silent] obsidian"
        "[workspace 4 silent] vesktop"
      ];
      input.follow_mouse = 0;
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
        "SUPER,T,exec,foot"
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

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/config";
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
    terminal = "foot";
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
          background:                  #${colors.bg}FF;
          background-alt:              #${colors.black}FF;
          foreground:                  #${colors.fg}FF;
          selected:                    #${colors.fg}FF;
          active:                      #${colors.cyan}FF;
          urgent:                      #${colors.red}FF;
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

  home.stateVersion = "25.11";
}
