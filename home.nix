{ config, lib, pkgs, user, bulkStore, ... }:

let
	dotfiles = "${config.home.homeDirectory}/.dotfiles";

	# Expo's Android toolchain: the SDK alone is ~10GB before a single emulator
	# image, and Gradle's cache grows without bound. bulkStore decides whether
	# that lands on the external drive or in the stock macOS locations.
	androidSdk =
		if bulkStore == null
		then "${config.home.homeDirectory}/Library/Android/sdk"
		else "${bulkStore}/Android/sdk";
in

{
	home.username = user;
	home.homeDirectory = "/Users/${user}";
	home.stateVersion = "26.05";
	home.packages = with pkgs; [
		jq        # json on the command line
		uv
	];

	home.sessionVariables = {
		JAVA_HOME = "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home";
		ANDROID_HOME = androidSdk;
	}
	# Only worth overriding when they would otherwise fill the internal drive;
	# on a roomy Mac the tools' own defaults are the better answer.
	// lib.optionalAttrs (bulkStore != null) {
		ANDROID_AVD_HOME = "${bulkStore}/Android/avd";
		GRADLE_USER_HOME = "${bulkStore}/Android/gradle";
	};

	home.sessionPath = [
		"${androidSdk}/platform-tools"   # adb
		"${androidSdk}/emulator"
		"${androidSdk}/cmdline-tools/latest/bin"
	];

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;      # ghost text from history
		syntaxHighlighting.enable = true;  # commands turn green when valid
		# Real .zsh files instead of a growing Nix string: no ''${...} escaping,
		# and editor syntax highlighting works. (N) is zsh's nullglob, so an
		# empty or missing directory is not an error.
		initContent = ''
			for f in ${config.xdg.configHome}/zsh/*.zsh(N); do
				source "$f"
			done
		'';
	};

	programs.starship = {
		enable = true;
		settings = {
			add_newline = false;
			# Language modules are self-hiding: nodejs only renders where a
			# package.json/.nvmrc/node_modules exists, golang only where a
			# go.mod/*.go does, python only where a pyproject.toml/requirements.txt
			# /.python-version does. Add more by appending $rust, $ruby, ... here.
			format = "$directory$git_branch$git_status$nodejs$golang$python$package$cmd_duration$line_break$character";
			character = {
				success_symbol = "[❯](purple)";
				error_symbol = "[❯](red)";
			};
			cmd_duration.format = "[$duration]($style) ";
			golang.symbol = " ";   # nerd-font glyphs, to match nodejs' default
			python.symbol = " ";
		};
	};

	programs.mise = {
		enable = true;
		enableZshIntegration = true;
		globalConfig.settings = {
			idiomatic_version_file_enable_tools = [ "node" ];
		};
	};

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
		sideloadInitLua = true;
	};

	programs.git = {
		enable = true;
		settings = {
			user.name = "Ajamal Khan";
			user.email = "13559558+khan-ajamal@users.noreply.github.com";
			init.defaultBranch = "main";
			# Track the executable bit, so a chmod +x on a script survives a clone
			# instead of coming back as 644 on the next machine.
			core.fileMode = true;
			diff.algorithm = "histogram";
			branch.sort = "-committerdate";
			alias = {
				s = "status -sb";
				lg = "log --oneline --graph --decorate -20";
			};
		};
		ignores = [ ".DS_Store" ".direnv/" "*.swp" "result" ];
	};

	programs.direnv = {
		# Drop a .envrc in a project, and entering that directory automatically loads its toolchain
		enable = true;
		nix-direnv.enable = true;
	};


	# Edit-in-place: the real file stays in my repo, ~/.config just points at it.
	home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
	home.file.".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty";
	home.file.".config/zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/zsh";

	home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
	home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
	home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
	home.file.".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
