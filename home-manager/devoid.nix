{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "devoid";
  home.homeDirectory = "/home/devoid";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;

    # Enable hyprland-session.target on hyprland startup
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      monitor = [
        # name, resolution, position, scale
        "DP-5,preferred,0x0,2"
        "eDP-1,preferred,auto,1"
        "DVI-I-1,disable"
        "DVI-I-2,disable"
      ];

      input = {
        # Rebind Ctl on CapsLock key
        kb_options = "ctrl:nocaps";

        # Touchpad / mouse related
        accel_profile = "adaptive";
        touchpad = {
          clickfinger_behavior = true;
          drag_lock = true;
        };
      };

      gestures = {
        workspace_swipe = true;
      };

      exec-once = [
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.dunst}/bin/dunst"
        # "${pkgs.swww}/bin/swww-daemon"
        "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator"
      ];

      # Bind flags
      #
      # l -> locked					m -> mouse
      # r -> release				t -> transparent
      # e -> repeat					s -> separate
      # n -> non-consuming  p -> bypass app

      bindle = [
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness raise"
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness lower"
      ];

      bind = let
        kitty = "${pkgs.kitty}/bin/kitty";
        binding = mod: cmd: key: arg: "${mod}, ${key}, ${cmd}, ${arg}";
        mvfocus = binding "SUPER" "movefocus";
        ws = binding "SUPER" "workspace";
        resizeactive = binding "SUPER CTRL" "resizeactive";
        mvactive = binding "SUPER ALT" "moveactive";
        mvtows = binding "SUPER SHIFT" "movetoworkspace";
        e = "exec";
        arr = [1 2 3 4 5 6 7];
      in
        [
          "SUPER, Return, exec, ${kitty}"
          "SUPER, W, exec, firefox"
          "SUPER, S, exec, ${pkgs.rofi-wayland}/bin/rofi -show drun -show-icons"

          "ALT, Tab, focuscurrentorlast"
          "CTRL ALT, Delete, exit"
          "ALT, Q, killactive"
          "SUPER, F, togglefloating"
          "SUPER, G, fullscreen"
          "SUPER, O, fakefullscreen"
          "SUPER, P, togglesplit"

          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"

          (mvfocus "k" "u")
          (mvfocus "j" "d")
          (mvfocus "l" "r")
          (mvfocus "h" "l")
          (ws "left" "e-1")
          (ws "right" "e+1")
          (mvtows "left" "e-1")
          (mvtows "right" "e+1")
          (resizeactive "k" "0 -20")
          (resizeactive "j" "0 20")
          (resizeactive "l" "20 0")
          (resizeactive "h" "-20 0")
          (mvactive "k" "0 -20")
          (mvactive "j" "0 20")
          (mvactive "l" "20 0")
          (mvactive "h" "-20 0")
        ]
        ++ (map (i: ws (toString i) (toString i)) arr)
        ++ (map (i: mvtows (toString i) (toString i)) arr);

      decoration = {
        drop_shadow = "yes";
        shadow_range = 8;
        shadow_render_power = 2;

        dim_inactive = false;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          new_optimizations = "on";
          noise = 0.01;
          contrast = 0.9;
          brightness = 0.8;
          popups = true;
        };
      };
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Window Manager Stuff
    pkgs.waybar
    pkgs.dunst
    pkgs.rofi-wayland # launcher
    pkgs.networkmanagerapplet
    pkgs.gopsuinfo # https://github.com/nwg-piotr/gopsuinfo
    pkgs.playerctl
    pkgs.pavucontrol
    pkgs.swww
    pkgs.mpvpaper
    pkgs.psensor

    # Coding
    pkgs.git
    pkgs.nil # Nix lsp implementation http://github.com/oxalica/nil

    # Utilities
    pkgs.keybase
    pkgs.keybase-gui
    pkgs.kbfs
    pkgs.htop
    pkgs.unzip
    pkgs.ffmpeg_7-full

    # Codecs
    pkgs.libwebp

    # Stupid Utilities
    pkgs.google-cloud-sdk

    # Browsers
    pkgs.chromium
    pkgs.firefox

    # Fun
    pkgs.cowsay
    pkgs.fortune
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["openmoji-black"];
        #   monospace = "";
        #   sansSerif = "";
        #   serif = "";
      };
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then ywou have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/devoid/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      hme = "pushd ~/dotfiles/home-manager; just rebuild";
      nixe = "pushd ~/dotfiles/nixos; just rebuild";
    };
  };
  programs.cava.enable = true;

  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      nvim-treesitter.withAllGrammars
    ];
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      set tabstop=2
      set shiftwidth=2
      syntax on
    '';
  };

  programs.spotify-player.enable = true;

  services.dunst.enable = true;
  programs.home-manager.enable = true;
  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.playerctld.enable = true;
  services.swayosd.enable = true;
  programs.waybar.enable = true;
}
