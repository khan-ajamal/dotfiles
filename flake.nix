{
	description = "dotfiles";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

		nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
		nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

		home-manager.url = "github:nix-community/home-manager/release-26.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";

		nix-homebrew.url = "github:zhaofengli/nix-homebrew";	
		nix-homebrew.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
		let
			user = "ajamalkhan";

			# Machine-shaped knob. Where bulky SDKs, caches and app bundles live
			# when the internal drive is too small to hold them. Set it to null on
			# a Mac with room to spare and every path below falls back to the
			# stock macOS location under $HOME and /Applications.
			bulkStore = "/Volumes/SSD";

			# Expo's Android toolchain: ~10GB of SDK before a single emulator
			# image, a Gradle cache that grows without bound, and a 2GB Studio
			# bundle. Derived here rather than in either module, because the
			# shell environment (home.nix) and the GUI environment
			# (configuration.nix) have to name the same directories or the CLI
			# and Android Studio end up writing to two different drives.
			android = rec {
				sdk =
					if bulkStore == null
					then "/Users/${user}/Library/Android/sdk"
					else "${bulkStore}/Android/sdk";

				# null leaves the Studio cask in /Applications.
				appdir = if bulkStore == null then null else "${bulkStore}/Applications";

				# The AVD and Gradle locations are only worth overriding when
				# they would otherwise fill the internal drive; on a roomy Mac
				# the tools' own defaults under $HOME are the better answer.
				env = { ANDROID_HOME = sdk; } // (
					if bulkStore == null then { } else {
						ANDROID_AVD_HOME = "${bulkStore}/Android/avd";
						GRADLE_USER_HOME = "${bulkStore}/Android/gradle";
					}
				);
			};
		in
		{
			darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
				specialArgs = { inherit user android; };
				modules = [
					./configuration.nix
					nix-homebrew.darwinModules.nix-homebrew
					home-manager.darwinModules.home-manager
					{
						home-manager.useGlobalPkgs = true;
						home-manager.useUserPackages = true;
						home-manager.extraSpecialArgs = { inherit user android; };
						home-manager.users.${user} = import ./home.nix;
						home-manager.backupFileExtension = "backup";
					}
				];
			};
		};
}
