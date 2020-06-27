# Derivation external dependencies (sources)
let    
    development = false;
    remoteSources = import ./nix/sources.nix; 
    localSources = {
        nixpkgs = <nixpkgs>;
        backup-sh = ../backup-sh;
        tasks-sh = ../tasks-sh;
    };
    defaultSources = if development then localSources else remoteSources;
in
# Source aliases
{ sources ? defaultSources }: 
with builtins; let
    pkgs = import sources.nixpkgs {};
    gitignore = import sources.gitignore {};
    gitignoreSource = gitignore.gitignoreSource;
    tasks-sh = import sources.tasks-sh {};
    backup-sh = import sources.backup-sh {};
in
# Derivation aliases
with pkgs; with lib; let
    store-tasks-json = name: tasks-config:
        writeText "${name}-backup-tasks.json" (toJSON tasks-config);
    store-backup-json = name: backup-config:
        writeText "${name}-backup-config.json" (toJSON backup-config);
    create-backup-task-config = backupTaskName: backup-config: 
        let
            backupConfig = store-backup-json backupTaskName backup-config.backupConfig;
        in filterAttrs (k: v: k != "backupConfig") backup-config // {
            inherit backupConfig;
        } // {
            task = "${writeScriptBin "${backupTaskName}-backup-exec.sh" ''
                BACKUP_CONFIG="${backupConfig}" ${backup-sh}/bin/backup.sh "$@"
            ''}/bin/${backupTaskName}-backup-exec.sh";
        } // optionalAttrs (hasAttr "pre" backup-config) {
            pre = "${(writeScriptBin "${backupTaskName}-backup-pre.sh" backup-config.pre)}/bin/${backupTaskName}-backup-pre.sh";
        } // optionalAttrs (hasAttr "post" backup-config) {
            post = "${(writeScriptBin "${backupTaskName}-backup-post.sh" backup-config.post)}/bin/${backupTaskName}-backup-post.sh";
        } // optionalAttrs (hasAttr "onfail" backup-config) {
            onfail = "${(writeScriptBin "${backupTaskName}-backup-onfail.sh" backup-config.post)}/bin/${backupTaskName}-backup-onfail.sh";
        };
    create-backup-tasks-config = tasksName: backup-configs: {
        tasks = map (backup-config: create-backup-task-config "${tasksName}-${backup-config.name}" backup-config) backup-configs;
    };
    create-backup-tasks = name: backup-configs:
        let
            tasks-config = create-backup-tasks-config name backup-configs;
            stored-tasks-json = store-tasks-json name tasks-config;
        in writeScriptBin "${name}-backup-sh" ''
            #!${pkgs.bash}/bin/bash

            TASKS_CONFIG="${stored-tasks-json}" ${tasks-sh}/bin/tasks.sh "$@"
        ''; 
# Derivation definition
in {
    inherit create-backup-tasks;
}