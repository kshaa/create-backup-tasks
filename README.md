# create-backup-tasks

A nix expression to configure [backup-sh](https://github.com/kshaa/backup-sh) and [tasks-sh](https://github.com/kshaa/tasks-sh)
for pre-configured backup execution.

## Environment
For testing you can use a pre-configured nix shell
```bash
# Environment dependencies
$ niv show
# Enter shell w/ test-backup-sh
$ nix-shell
```

## Usage
```bash
# Backup tasks help
$ test-backup-sh help
# List backup tasks
$ test-backup-sh get
# List backup tasks configuration
$ test-backup-sh dump

# Get 'nix-folder' backup help
$ test-backup-sh exec name nix-folder -- help
# Create 'nix-folder' backup
$ test-backup-sh exec name nix-folder -- create
# List 'nix-folder' backups
$ test-backup-sh exec name nix-folder -- get

# Create all backups with a group 'whole-backup'
$ test-backup-sh exec -- create groups whole-backup
# List all backups
$ test-backup-sh exec -- get
# Restore all latest backups with group 'whole-backup'
$ test-backup-sh exec -- restore groups whole-backup
# Delete all backups
$ test-backup-sh exec -- delete

# In case of emergency, execute backups directly without tasks.sh abstraction
# by parsing tasks.sh configuration dump and fetching the backup script
# E.g. get nix-folder backups directly through backup.sh
$ "$(test-backup-sh dump | jq -r '.tasks[] | select(.name == "nix-folder") | .task')" get
```
