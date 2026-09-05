{ config, pkgs, user, ... }:

let
	dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
	home.username = user;
	home.homeDirectory = "/Users/${user}";
	home.stateVersion = "26.05";
	home.packages = with pkgs; [
		jq        # json on the command line
		uv
	];

	programs.zsh = {
		enable = true;
		autosuggestion.enable = true;      # ghost text from history
		syntaxHighlighting.enable = true;  # commands turn green when valid
		initContent = ''
			bindkey '^f' autosuggest-accept
		'';
	};
	
	programs.mise = {
		enable = true;
		enableZshIntegration = true;
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
			user.email = "ajamalkhan65@gmail.com";
			extraConfig = {
				init.defaultBranch = "main";
				diff.algorithm = "histogram";
				branch.sort = "-committerdate";
			};
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
	home.file.".claude/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";


	home.file.".claude/CLAUDE.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
	home.file.".codex/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
	home.file.".config/opencode/AGENTS.md".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
