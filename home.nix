{ config, pkgs, ...} :
{
	home.username = "johncarlojose";
	home.homeDirectory = "/home/johncarlojose";
	home.stateVersion = "25.11";
	home.file.".config/qtile/config.py".source = ./qtile/config.py;
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
