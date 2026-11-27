{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Nix settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader (grub)
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "pine";

  # Network configuration (networkmanager)
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Asia/Ho_Chi_Minh";

  # Setup zswap
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 6*1024;
  }];

  boot.zswap = {
    enable = true;
    maxPoolPercent = 25;
    shrinkerEnabled = true;
    compressor = "zstd";
    acceptThresholdPercent = 90;
  };

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
#    useXkbConfig = true;
  };

  # Input method (fcitx5)
 i18n.inputMethod = {
   type = "fcitx5";
   enable = true;
   fcitx5.addons = with pkgs; [
     fcitx5-bamboo
     kdePackages.fcitx5-qt
   ];
   fcitx5.waylandFrontend = true;
 };

  # X11 configuration
  # services.xserver.enable = true;
  services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Sound (pipewire)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  ## Bluetooth
  hardware.bluetooth.enable = true;

  # User account
  users.users.cgik = {
    isNormalUser = true;
    description = "cgik";
    extraGroups = [ "wheel" "audio" "video" "podman" ];
    shell = pkgs.fish;
    home = "/home/cgik";
  };

  # KDE Plasma
  ## Exclude some packages to be installed
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    okular
    ktnef
    elisa
    qrca
  ];
  programs.kde-pim.kontact = false;
  programs.kde-pim.kmail = false;
  programs.kde-pim.merkuro = false;

  services = {
    displayManager.plasma-login-manager.enable = true;
    desktopManager.plasma6.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs.kdePackages; [
      xdg-desktop-portal-kde
    ];
  };

  # Programs configuration
  environment.systemPackages = [
    # KDE programs
    pkgs.kdePackages.discover
    pkgs.kdePackages.partitionmanager
    pkgs.kdePackages.kcolorchooser
    pkgs.kdePackages.bluedevil
    pkgs.kdePackages.kup

    # System utilities
    pkgs.wayland-utils
    pkgs.wl-clipboard
    pkgs.wget
    pkgs.fastfetch
    pkgs.vlc
    pkgs.git
    pkgs.distrobox
    pkgs.icoutils
    ## Vulkan
    pkgs.vulkan-loader
    pkgs.vulkan-tools

    # Applications
    pkgs.umu-launcher
    pkgs.vesktop
    pkgs.ayugram-desktop
    pkgs.gh
    inputs.firefox.packages.${pkgs.stdenv.hostPlatform.system}.firefox-nightly-bin
    inputs.vermouth.packages.${pkgs.stdenv.hostPlatform.system}.default
    ## Wine
    pkgs.wineWow64Packages.waylandFull
  ];
  programs.fish.enable = true;
  programs.firefox.enable = true;
  ## Enable Appimages
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Flatpak
  services.flatpak.enable = true;

  # Some other stuff
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Services
  # services.openssh.enable = true;

  # shhhh
  system.stateVersion = "26.11";

}
