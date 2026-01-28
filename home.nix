{
  pkgs,
  config,
  nix4nvchad,
  ...
}: {
  imports = [nix4nvchad.homeManagerModule];

  home.username = "user";
  home.homeDirectory = "/home/user";

  home.packages = with pkgs; [
    # CLI
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
    delta
    usbmuxd
    zip
    unzip
    unrar

    # GUI
    wl-clipboard
    grim
    slurp
    swaybg
    hyprpaper
    pavucontrol
    brightnessctl
    nautilus
    bibata-cursors

    # Dev / Languages
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

    # Apps
    obsidian
    localsend
    opencode
    syncthing
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
        };
      }
    '';

    extraConfig = ''
      local map = vim.keymap.set

      vim.o.wrap = false
      map("n", ";", ":", { desc = "CMD enter command mode" })
      map({ "n", "v" }, "J", "<C-d>", { desc = "Go Down" })
      map({ "n", "v" }, "K", "<C-u>", { desc = "Go Up" })
      map("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      map("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    '';

    chadrcConfig = ''
      local M = {}
      M.ui = { theme = "everblush" }
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
        everblush = {
          fg = "#dadada";
          bg = "#141b1e";
          black = "#232a2d";
          red = "#e57474";
          green = "#8ccf7e";
          yellow = "#e5c76b";
          blue = "#67b0e8";
          magenta = "#c47fd5";
          cyan = "#6cbfbf";
          white = "#b3b9b8";
          orange = "#ff9e64";
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
              border_format   "#[fg=#b3b9b8]{char}"
              border_position "top"

              datetime        "#[fg=#b3b9b8] {format} "
              datetime_format "%d %b %Y %H:%M"
              datetime_timezone "Hongkong"

              tab_normal  "#[bg=#141b1e,fg=#67b0e8] {index} "
              tab_active  "#[bg=#232a2d,fg=#e5c76b,bold] {index} "
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

    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=18:style=Semibold";
        pad = "6x6 center";
        shell = "fish";
      };

      cursor = {
        style = "underline";
        color = "dadada dadada";
      };

      colors = {
        background = "141b1e";
        foreground = "dadada";

        regular0 = "232a2d"; # black
        regular1 = "e57474"; # red
        regular2 = "8ccf7e"; # green
        regular3 = "e5c76b"; # yellow
        regular4 = "67b0e8"; # blue
        regular5 = "c47fd5"; # magenta
        regular6 = "6cbfbf"; # cyan
        regular7 = "b3b9b8"; # white

        bright0 = "2d3437"; # black
        bright1 = "ef7e7e"; # red
        bright2 = "96d988"; # green
        bright3 = "f4d67a"; # yellow
        bright4 = "71baf2"; # blue
        bright5 = "ce89df"; # magenta
        bright6 = "67cbe7"; # cyan
        bright7 = "bdc3c2"; # white
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };

  # programs.kitty = {
  #   enable = true;
  #
  #   font = {
  #     name = "JetBrainsMono Nerd Font";
  #     size = 18;
  #   };
  #
  #   settings = {
  #     # --- Fonts ---
  #     bold_font = "auto";
  #     italic_font = "auto";
  #     bold_italic_font = "auto";
  #
  #     # --- Window ---
  #     confirm_os_window_close = 0;
  #     # background_opacity = "1.0";
  #     # dynamic_background_opacity = "no";
  #     # dim_opacity = "0";
  #     # window_padding_width = 6;
  #     # linux_display_server = "auto";
  #
  #     # --- Behavior ---
  #     # cursor_trail = 1;
  #     shell = "fish";
  #     editor = "nvim";
  #     scrollback_lines = 2000;
  #     wheel_scroll_min_lines = 1;
  #     enable_audio_bell = "no";
  #
  #     # --- Base Colors ---
  #     foreground = "#dadada";
  #     background = "#141b1e";
  #     selection_foreground = "#dadada";
  #     selection_background = "#2d3437";
  #
  #     # --- Cursor ---
  #     cursor = "#2d3437";
  #     cursor_text_color = "#dadada";
  #
  #     # --- Normal Colors ---
  #     color0 = "#141b1e";
  #     color1 = "#e57474";
  #     color2 = "#8ccf7e";
  #     color3 = "#e5c76b";
  #     color4 = "#67b0e8";
  #     color5 = "#c47fd5";
  #     color6 = "#6cbfbf";
  #     color7 = "#b3b9b8";
  #
  #     # --- Bright Colors ---
  #     color8  = "#2d3437";
  #     color9  = "#ef7e7e";
  #     color10 = "#96d988";
  #     color11 = "#f4d67a";
  #     color12 = "#71baf2";
  #     color13 = "#ce89df";
  #     color14 = "#67cbe7";
  #     color15 = "#bdc3c2";
  #
  #     # --- Tab Colors ---
  #     active_tab_foreground   = "#e182e0";
  #     active_tab_background   = "#141b1e";
  #     inactive_tab_foreground = "#cd69cc";
  #     inactive_tab_background = "#141b1e";
  #   };
  # };

  # programs.alacritty = {
  #   enable = true;
  #
  #   settings = {
  #     font = {
  #       size = 18;
  #       normal = {
  #         family = "JetBrainsMono Nerd Font";
  #         style = "Semibold";
  #       };
  #     };
  #
  #     window = {
  #       dynamic_padding = true;
  #     };
  #
  #     cursor = {
  #       style = {
  #         shape = "Underline";
  #       };
  #     };
  #
  #     colors = {
  #       primary = {
  #         background = "0x141b1e";
  #         foreground = "0xdadada";
  #       };
  #
  #       cursor = {
  #         text = "0xdadada";
  #         cursor = "0xdadada";
  #       };
  #
  #       normal = {
  #         black   = "0x232a2d";
  #         red     = "0xe57474";
  #         green   = "0x8ccf7e";
  #         yellow  = "0xe5c76b";
  #         blue    = "0x67b0e8";
  #         magenta = "0xc47fd5";
  #         cyan    = "0x6cbfbf";
  #         white   = "0xb3b9b8";
  #       };
  #
  #       bright = {
  #         black   = "0x2d3437";
  #         red     = "0xef7e7e";
  #         green   = "0x96d988";
  #         yellow  = "0xf4d67a";
  #         blue    = "0x71baf2";
  #         magenta = "0xce89df";
  #         cyan    = "0x67cbe7";
  #         white   = "0xbdc3c2";
  #       };
  #     };
  #
  #     terminal = {
  #       shell = "fish";
  #       osc52 = "CopyPaste";
  #     };
  #   };
  # };

  # programs.ghostty = {
  #   enable = true;
  #
  #   settings = {
  #     background = "141b1e";
  #     font-size = 18;
  #     font-family = "JetBrainsMono Nerd Font Mono";
  #     font-style = "Semibold";
  #     theme = "Everblush";
  #     shell-integration = "fish";
  #     command = "fish";
  #
  #     confirm-close-surface = false;
  #
  #     window-padding-x = 6;
  #     window-padding-y = 6;
  #
  #     keybind = "ctrl+shift+j=unbind";
  #
  #     custom-shader-animation = "always";
  #     custom-shader = "shaders/cursor_sweep.glsl";
  #   };
  # };
  #

  # xdg.configFile."ghostty/shaders/cursor_sweep.glsl".text = ''vec4 TRAIL_COLOR = iCurrentCursorColor;  const float DURATION = 0.2;  const float TRAIL_LENGTH = 0.5; const float BLUR = 2.0;   const float PI = 3.14159265359; const float C1_BACK = 1.70158; const float C2_BACK = C1_BACK * 1.525; const float C3_BACK = C1_BACK + 1.0; const float C4_ELASTIC = (2.0 * PI) / 3.0; const float C5_ELASTIC = (2.0 * PI) / 4.5; const float SPRING_STIFFNESS = 9.0; const float SPRING_DAMPING = 0.9;           float ease(float x) { return 1.0 - pow(1.0 - x, 3.0); }                                       float getSdfRectangle(in vec2 point, in vec2 center, in vec2 halfSize) { vec2 d = abs(point - center) - halfSize; return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0); }   float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) { vec2 e = b - a; vec2 w = p - a; vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0); float segd = dot(p - proj, p - proj); d = min(d, segd); float c0 = step(0.0, p.y - a.y); float c1 = 1.0 - step(0.0, p.y - b.y); float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x); float allCond = c0 * c1 * c2; float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2); float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond)); s *= flip; return d; } float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) { float s = 1.0; float d = dot(p - v0, p - v0); d = seg(p, v0, v3, s, d); d = seg(p, v1, v0, s, d); d = seg(p, v2, v1, s, d); d = seg(p, v3, v2, s, d); return s * sqrt(d); } vec2 normalize(vec2 value, float isPosition) { return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y; } float antialising(float distance) { return 1. - smoothstep(0., normalize(vec2(BLUR, BLUR), 0.).x, distance); } float getTopVertexFlag(vec2 a, vec2 b) { float condition1 = step(b.x, a.x) * step(a.y, b.y);  float condition2 = step(a.x, b.x) * step(b.y, a.y);   return 1.0 - max(condition1, condition2); } vec2 getRectangleCenter(vec4 rectangle) { return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.)); } void mainImage(out vec4 fragColor, in vec2 fragCoord){#if !defined(WEB) fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);#endif  vec2 vu = normalize(fragCoord, 1.); vec2 offsetFactor = vec2(-.5, 0.5); vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.)); vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.)); vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor); vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor); float sdfCurrentCursor = getSdfRectangle(vu, centerCC, currentCursor.zw * 0.5); float lineLength = distance(centerCC, centerCP); vec4 newColor = vec4(fragColor); float minDist = currentCursor.w * 1.5; float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0); if (lineLength > minDist) {  float shrinkFactor = ease(progress);  vec2 delta = abs(centerCC - centerCP); float threshold = 0.001; float isHorizontal = step(delta.y, threshold); float isVertical = step(delta.x, threshold); float isStraightMove = max(isHorizontal, isVertical);  float topVertexFlag = getTopVertexFlag(currentCursor.xy, previousCursor.xy); float bottomVertexFlag = 1.0 - topVertexFlag; vec2 v0 = vec2(currentCursor.x + currentCursor.z * topVertexFlag, currentCursor.y - currentCursor.w); vec2 v1 = vec2(currentCursor.x + currentCursor.z * bottomVertexFlag, currentCursor.y); vec2 v2_full = vec2(previousCursor.x + currentCursor.z * bottomVertexFlag, previousCursor.y); vec2 v3_full = vec2(previousCursor.x + currentCursor.z * topVertexFlag, previousCursor.y - previousCursor.w); vec2 v2_start = mix(v1, v2_full, TRAIL_LENGTH); vec2 v3_start = mix(v0, v3_full, TRAIL_LENGTH); vec2 v2_anim = mix(v2_start, v1, shrinkFactor); vec2 v3_anim = mix(v3_start, v0, shrinkFactor); float sdfTrail_diag = getSdfParallelogram(vu, v0, v1, v2_anim, v3_anim);  vec2 min_center = min(centerCP, centerCC); vec2 max_center = max(centerCP, centerCC); vec2 bBoxSize_full = (max_center - min_center) + currentCursor.zw; vec2 bBoxCenter_full = (min_center + max_center) * 0.5; vec2 bBoxSize_start = mix(currentCursor.zw, bBoxSize_full, TRAIL_LENGTH); vec2 bBoxCenter_start = mix(centerCC, bBoxCenter_full, TRAIL_LENGTH); vec2 animSize = mix(bBoxSize_start, currentCursor.zw, shrinkFactor); vec2 animCenter = mix(bBoxCenter_start, centerCC, shrinkFactor); float sdfTrail_rect = getSdfRectangle(vu, animCenter, animSize * 0.5);  float sdfTrail = mix(sdfTrail_diag, sdfTrail_rect, isStraightMove); vec4 trail = TRAIL_COLOR; float trailAlpha = antialising(sdfTrail); newColor = mix(newColor, trail, trailAlpha);  newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.)); } fragColor = newColor; }'';
  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    settings = {
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
        "swaybg -i ~/config/bin/wallpaper.png"
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

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
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
        ",Print,exec, slurp | grim -g - - | wl-copy"
        "SUPER,SUPER_L,exec,rofi -show drun || pkill rofi"
        "SUPER SHIFT,S,exec,hyprpicker -a"
        "SUPER,W,exec,waybar"
        "SUPER,C,exec,vesktop"
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

    location = "center";
    font = "JetBrainsMono Nerd Font 16";
    terminal = "foot";
    cycle = true;

    modes = [
      "drun"
      "run"
      "filebrowser"
      "ssh"
      "window"
    ];

    extraConfig = {
      show-icons = false;
      "display-drun" = " Apps";
      "display-run" = " Run";
      "display-filebrowser" = " Files";
      "display-window" = " Windows";
      "display-ssh" = " SSH";
      "drun-display-format" = "{name}";
      "window-format" = "{w} · {c} · {t}";
      "case-sensitive" = false;
      matching = "normal";
      sort = true;
      "click-to-exit" = true;
      "parse-hosts" = true;
      "parse-known-hosts" = true;
      "ssh-client" = "ssh";
      "ssh-command" = "{terminal} -e {ssh-client} {host} [-p {port}]";
    };

    theme = {
      "*" = {
        bg = "#141b1eFF";
        bg-alt = "#232a2dFF";
        fg = "#dadadaFF";
        selected = "#dadadaFF";
        active = "#6cbfbfFF";
        urgent = "#e57474FF";
      };

      window = {
        width = "800px";
        margin = "12px";
        padding = "0px";
        "border-radius" = "0px 0px 12px 12px";
        "background-color" = "#141b1eFF";
      };

      mainbox = {
        spacing = "10px";
        padding = "20px";
        "background-color" = "#141b1eFF";
        children = ["inputbar" "message" "custombox"];
      };

      custombox = {
        spacing = "10px";
        "background-color" = "#141b1eFF";
        orientation = "horizontal";
        children = ["mode-switcher" "listview"];
      };

      inputbar = {
        spacing = "10px";
        padding = "8px 12px";
        "border-radius" = "8px";
        "background-color" = "#232a2dFF";
        children = ["textbox-prompt-colon" "entry"];
      };

      "textbox-prompt-colon" = {
        enabled = true;
        padding = "5px 0px";
        str = "";
        "background-color" = "inherit";
      };

      entry = {
        enabled = true;
        padding = "5px 0px";
        placeholder = "Search...";
        "background-color" = "inherit";
      };

      listview = {
        columns = 1;
        lines = 8;
        dynamic = true;
        scrollbar = true;
        layout = "vertical";
        spacing = "5px";
        "background-color" = "transparent";
      };

      scrollbar = {
        "handle-width" = "5px";
        "handle-color" = "#dadadaFF";
        "border-radius" = "10px";
        "background-color" = "#232a2dFF";
      };

      element = {
        spacing = "10px";
        padding = "10px";
        "border-radius" = "8px";
        "background-color" = "transparent";
        "text-color" = "#dadadaFF";
      };

      "element normal.normal" = {
        "background-color" = "transparent";
        "text-color" = "#dadadaFF";
      };

      "element selected.normal" = {
        "background-color" = "#dadadaFF";
        "text-color" = "#141b1eFF";
      };

      "element normal.active" = {
        "background-color" = "#6cbfbfFF";
        "text-color" = "#141b1eFF";
      };

      "element normal.urgent" = {
        "background-color" = "#e57474FF";
        "text-color" = "#141b1eFF";
      };

      "element selected.active" = {
        "background-color" = "#6cbfbfFF";
        "text-color" = "#141b1eFF";
      };

      "element selected.urgent" = {
        "background-color" = "#e57474FF";
        "text-color" = "#141b1eFF";
      };

      "element alternate.normal" = {
        "background-color" = "transparent";
        "text-color" = "#dadadaFF";
      };

      "element alternate.active" = {
        "background-color" = "#6cbfbfFF";
        "text-color" = "#141b1eFF";
      };

      "element alternate.urgent" = {
        "background-color" = "#e57474FF";
        "text-color" = "#141b1eFF";
      };

      "element-icon" = {
        size = "24px";
        "background-color" = "transparent";
      };

      "mode-switcher" = {
        enabled = true;
        expand = false;
        orientation = "vertical";
        spacing = "10px";
        "background-color" = "transparent";
      };

      button = {
        padding = "0px 20px";
        "border-radius" = "8px";
        "background-color" = "#232a2dFF";
        "text-color" = "#dadadaFF";
      };

      "button selected" = {
        "background-color" = "#dadadaFF";
        "text-color" = "#141b1eFF";
      };
    };
  };

  home.stateVersion = "25.11";
}
