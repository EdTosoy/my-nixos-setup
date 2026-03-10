{ config, pkgs, ...} :
{
	home.username = "johncarlojose";
	home.homeDirectory = "/home/johncarlojose";
	home.stateVersion = "25.11";
	home.file.".config/qtile/config.py".source = ./qtile/config.py;
	home.pointerCursor = 
    let 
      getFrom = url: hash: name: {
          gtk.enable = true;
          name = name;
          size = 48;
          package = 
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom 
        "https://github.com/dreamsofautonomy/banana-cursor/releases/download/v2.2.0/Banana.tar.xz"
        "sha256-FA7iKldiuvWizVcrbANGAKgtQ3r/7nQovn2Lk+utvIU="
        "Banana";
	programs.bash = {
		enable = true;
		shellAliases = {
			btw = "echo I use nixos, btw";
		};
	};
	programs.git = {
  		enable = true;
  		settings = {
    		user.name = "edtosoy";
    		user.email = "edberto.tosoy@gmail.com";
  		};
	};
}
