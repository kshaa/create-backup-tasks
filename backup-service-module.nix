# module external sources
{ sources }:
let
    pkgs = import sources.nixpkgs {};
    gitignore = import sources.gitignore {};
    gitignoreSource = gitignore.gitignoreSource;
    tasks-sh = import sources.tasks-sh {};
    backup-sh = import sources.backup-sh {};
    create-backup-tasks = import ./create-backup-tasks.nix { inherit sources; };
in { config, lib, pkgs, ...}:
# module aliases
let
    cfg = config.services.system-backup-tasks;
    system-backup-tasks = create-backup-tasks "system" cfg.backupConfigs;
in with lib; {
  options.services.system-backup-tasks = {
    enable = mkEnableOption "System backup task service";
    backupConfigs = mkOption { type = types.listOf types.attrs; default = []; };
    backupTaskCommand = mkOption { type = types.str; default = "exec -- create groups $(date +\"%Y-%m-%d-%H-%M-%S\")"; };
    restoreTaskCommand = mkOption { type = types.str; default = "exec -- restore"; };
  };

  config = mkIf cfg.enable {
    security.wrappers = {
      system-backup-sh = {
        group = "root";
        owner = "root";
        permissions = "a+rx";
        setgid = false;
        setuid = true;
        source = "${system-backup-tasks}/bin/system-backup-sh";
      };
    };
    # environment.systemPackages = [ system-backup-tasks ];
    systemd.services.system-backup = {
      script = "${system-backup-tasks}/bin/system-backup-sh ${cfg.backupTaskCommand}";
    };
    systemd.services.system-restore = {
      script = "${system-backup-tasks}/bin/system-backup-sh ${cfg.restoreTaskCommand}";
    };
  };
}