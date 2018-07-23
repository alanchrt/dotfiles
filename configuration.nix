# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "9480m"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Central";

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    python3 python36Packages.virtualenv python36Packages.virtualenvwrapper nodejs-9_x ruby pcmanfm wget whois xclip xautolock i3lock-fancy dunst notify-desktop nitrogen dropbox compton networkmanagerapplet pavucontrol i3blocks acpi sysstat unclutter rofi flameshot termite git byobu tmux tmate vim emacs jq httpie chromium virtualbox minikube kubectl kubernetes-helm nfs-utils redshift yubioath-desktop yubikey-manager libqalculate aws zathura ag ardour
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Include fonts.
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    ubuntu_font_family
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable power management.
  services.tlp.enable = true;

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    layout = "us";

    # Enable touchpad support.
    libinput.enable = true;

    # Don't use a dekstop manager.
    desktopManager = {
      default = "none";
      xterm.enable = false;
    };

    # Enable autologin.
    displayManager.auto = {
      enable = true;
      user = "alan";
    };

    # Use i3 as window manager
    windowManager = {
      default = "i3";

      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.alan = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" ];
    shell = pkgs.zsh;
  };

  # Android devices.
  programs.adb.enable = true;

  # Enable docker
  virtualisation.docker.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
  system.autoUpgrade.enable = true;

}
