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
    backup-sh = import sources.backup-sh {};
    tasks-sh = import sources.tasks-sh {};
    create-backup-tasks = import ./create-backup-tasks.nix { inherit sources; };
    backup-service-module = import ./backup-service-module.nix { inherit sources; };
# Derivation definition
in {
    inherit 
        tasks-sh
        backup-sh
        create-backup-tasks
        backup-service-module;
}