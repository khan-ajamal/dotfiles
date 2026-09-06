{ pkgs, user, bulkStore, ... }:

let
	# Android Studio is ~2GB of app bundle. appdir only moves the bundle; the SDK,
	# AVD images and Gradle caches are the tens of gigabytes, and home.nix steers
	# those with the Android environment variables.
	android-studio =
		if bulkStore == null
		then "android-studio"
		else { name = "android-studio"; args.appdir = "${bulkStore}/Applications"; };
in

{
	# Determinate already manges the Nix daemon, so nix-darwin shouldn't
	nix.enable = false;

	nixpkgs.config.allowUnfree = true;
	nixpkgs.hostPlatform = "aarch64-darwin";

	system.primaryUser = user;
	users.users.${user} = {
		home = "/Users/${user}";
	};

	programs.zsh = {
		enable = true;
		enableCompletion = false;
	};

	# Ghostty embeds Symbols Nerd Font, so the starship language glyphs already
	# render there. Installing it system-wide means they survive a move to any
	# other terminal instead of degrading to tofu boxes.
	fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
	# It is not a version of nix-darwin — it's a marker of which release you first set this machine up under. Some settings changed defaults over time in ways that would break existing systems, so nix-darwin keys those behaviors off this number. Set it once at install, then leave it alone forever. Bumping it later can silently change how things behave.
	system.stateVersion = 6;

	system.defaults = {
		NSGlobalDomain = {
			AppleInterfaceStyle = "Dark";
			AppleShowAllExtensions = true;
			NSDocumentSaveNewDocumentsToCloud = false;
		};
		dock = {
			autohide = true;
			tilesize = 36;
			magnification = true;
			largesize = 64;
			persistent-apps = [
				{
					app = "/System/Applications/App Store.app";
				}
				{
					app = "/System/Applications/System Settings.app";
				}
				{
					app = "/Applications/Ghostty.app";
				}
				{
					app = "/Applications/Obsidian.app";
				}
				{
					app = "/Applications/Visual Studio Code.app";
				}
				{
					app = "/Applications/Google Chrome.app";
				}
			];
			show-recents = false;
		};
		finder = {
			FXRemoveOldTrashItems = true;
			ShowExternalHardDrivesOnDesktop = false;
			ShowPathbar = true;
			FXPreferredViewStyle = "Nlsv";
			ShowStatusBar = true;
			_FXEnableColumnAutoSizing = true;
			_FXSortFoldersFirst = true;
			_FXSortFoldersFirstOnDesktop = true;
			FXDefaultSearchScope = "SCcf";
			_FXShowPosixPathInTitle = true;
		};

		controlcenter.BatteryShowPercentage = true;
		trackpad.Clicking = true;
	};
	nix-homebrew = {
		enable = true;
		autoMigrate = true;
		inherit user;
	};

	homebrew = {
		enable = true;
	    	onActivation.cleanup = "uninstall";
	    	onActivation.autoUpdate = true;
		onActivation.upgrade = true;
		enableZshIntegration = true;

        brews = [ "cocoapods" ];

		casks = [
			"google-chrome"
			"ghostty"
			"claude-code"
			"obsidian"
			"visual-studio-code"

			# Expo Android builds. Expo pins Zulu 17 specifically, since Gradle
			# needs a JDK 17. Its .pkg always lands in /Library/Java and cannot be
			# relocated, but that is only ~330MB.
			"zulu@17"
			android-studio
		];
	};
}
