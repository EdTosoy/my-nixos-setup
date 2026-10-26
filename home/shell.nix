{ config, ... }:
let
  pnpmShellInit = ''
    # Refresh long-lived parent environments even when HM session vars were sourced.
    export PNPM_HOME="${config.home.sessionVariables.PNPM_HOME}"
    case ":$PATH:" in
      *:"$PNPM_HOME/bin":*) ;;
      *) export PATH="$PNPM_HOME/bin''${PATH:+:$PATH}" ;;
    esac
  '';
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  #################################
  # Shell
  #################################
  programs.bash = {
    enable = true;
    profileExtra = pnpmShellInit;
    initExtra = pnpmShellInit;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    shellAliases = {
      btw = "echo I use nixos, btw";
      # Rebuilds the NixOS system, including the "nvim submodule" content.
      nrs = "sudo nixos-rebuild switch --flake ~/'nixos-setup?submodules=1#nixos-btw'";
      nix-clean = "sudo nix-collect-garbage -d";

      # Git
      ## Basic workflow
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
      gp = "git push";
      gpff = "git pull --ff-only";
      gm = "git merge";
      gf = "git fetch";
      glo = "git log --oneline --graph --decorate";
      ## Branch
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      ## Rebase
      grb = "git rebase";
      grbi = "git rebase -i";
      grc = "git rebase --continue";
      gra = "git rebase --abort";
      ## Cherry-pick & revert
      gcp = "git cherry-pick";
      grev = "git revert";
      ## Reset & recovery
      grs = "git reset --soft HEAD~1";
      grl = "git reflog";
      ## Stash
      gst = "git stash";
      gstm = "git stash -m";
      gstp = "git stash pop";
      gstl = "git stash list";
      ## Worktree
      gwta = "git worktree add";
      gwtl = "git worktree list";
      gwtr = "git worktree remove";
      ## Bisect
      gbs = "git bisect start";
      gbsg = "git bisect good";
      gbsb = "git bisect bad";
      gbsr = "git bisect reset";
      ## Inspect
      grm = "git remote";
      gd = "git diff";
      gsh = "git show";
      gcf = "git cat-file -p";

      # Terraform
      tf = "terraform";
      tfi = "terraform init";
      tfp = "terraform plan";
      tfa = "terraform apply";
      tfd = "terraform destroy";
      tfv = "terraform validate";
      tff = "terraform fmt";
      tffr = "terraform fmt -recursive";
      tfo = "terraform output";
      tfs = "terraform state";
      tfsl = "terraform state list";
      tfw = "terraform workspace";
      tfwl = "terraform workspace list";
      tfws = "terraform workspace select";
      tfc = "terraform console";
      tfg = "terraform graph";
      tfsh = "terraform show";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      # Dev
      v = "nvim";
      nx = "pnpm nx";
      grep = "rg";
      ls = "eza --icons";
      ll = "eza -al --icons";
      la = "eza -A --icons";
      ts = "tmux-sessionizer";
      tks = "tmux kill-server";
    };
  };

}
