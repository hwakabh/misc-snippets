# GitLab backup utilities

- Make backups of following GitLab configurations
  - `/etc/gitlab/*`
    - Base configurations of GitLab environments
  - User data within GitLab system databases
    - With `gitlab-rake`, create backups of repository data

- Pre-requirements
  - Before running script, the target directories must be created by user.
    - Confirm that the directory would be created
    - Modify the paramenters `PATH_TO_DIR_BACKUP_SAVED` and `PATH_TO_TARGET_DIR_TO_BACKUP` in the script

- Run the script
  - `bash ./get_daily_gitbk.sh`
    - It should be better that you execute the script with `crond` so that you could get daily backups.
