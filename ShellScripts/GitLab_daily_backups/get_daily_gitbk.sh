#!/bin/bash
## Before you run the script:
## - Make sure the backup directories would have already created

## - Change variables below for your environments
##   examples:
##     BKDIR=/var/backup/gitlab.bk
##     DEFDIR=/var/opt/gitlab/backups
BKDIR=PATH_TO_DIR_BACKUP_SAVED
DEFDIR=PATH_TO_TARGET_DIR_TO_BACKUP

# Get GitLab Configurations backups
tar cfz ${BKDIR}/$(date "+%s_%Y_%m_%d_etc_gitlab.tar.gz") -C /etc gitlab

# Backing up repository data with Rails
/opt/gitlab/bin/gitlab-rake gitlab:backup:create

# Copy repository data to backup directory
cp -rp ${DEFDIR}/* $BKDIR

# Lotations
find $BKDIR -mtime +2 |xargs rm -rf
find $DEFDIR -mtime +2 |xargs rm -rf
