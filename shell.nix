# Shell external dependencies (sources)
let
    development = true;
    remoteSources = import ./nix/sources.nix; 
    localSources = {
        nixpkgs = <nixpkgs>;
        backup-sh = ../backup-sh;
        tasks-sh = ../tasks-sh;
    };
    defaultSources = if development then localSources else remoteSources;
in { sources ? defaultSources }: 
# Source aliases
let
    pkgs = import sources.nixpkgs {};
    # tasks-sh = import sources.tasks-sh {};
    # backup-sh = import sources.backup-sh {};
    backup-service = import ./. {};
    create-backup-tasks = backup-service.create-backup-tasks;
in
# Shell aliases
with pkgs; let
    ## Test backup
    test-backups = create-backup-tasks "test" [
        rec {
            name = "readme";
            groups = [ "single" "backup" "readme" "text" ];
            description = "README.md backup task";
            backupConfig = {
                inherit name description;
                type = "local";
                acl = true;
                resource_type = "file";
                resource_path = toString ./README.md;
                storage_path = toString ./.;
            };
            post = ''
                #!${bash}/bin/bash
                echo "Successful task! :)"
            '';
            onfail = ''
                #!${bash}/bin/bash
                echo "Task failed! :("
            '';
        }
        rec {
            name = "nix-folder";
            groups = [ "multiple" "backup" "nix" "folder" ];
            description = "nix/ directory backup task";
            backupConfig = {
                inherit name description;
                type = "local";
                acl = true;
                resource_type = "directory";
                resource_path = toString ./nix;
                storage_path = toString ./.;
            };
            post = ''
                #!${bash}/bin/bash
                echo "Successful task! :)"
            '';
            onfail = ''
                #!${bash}/bin/bash
                echo "Task failed! :("
            '';
        }
    ];
# Shell definition
in pkgs.mkShell {
    buildInputs = [
        test-backups
    ];
}
