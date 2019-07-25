#!/bin/bas
## Before you run:
## - Make sure the directories would have already created

## - Adjust variables below for your environments
##   e.g.
##   BKDIR=/var/backup/gitlab.bk
##   DEFDIR=/var/opt/gitlab/backups
BKDIR=/var/backup/gitlab.bk
DEFDIR=/var/opt/gitlab/backups

# Get GitLab Configurations backups
tar cfz ${BKDIR}/$(date "+%s_%Y_%m_%d_etc_gitlab.tar.gz") -C /etc gitlab

# Backing up repository data with Rails
/opt/gitlab/bin/gitlab-rake gitlab:backup:create

# Copy repository data to backup directory
cp -rp ${DEFDIR}/* $BKDIR

# Lotations
find $BKDIR -mtime +2 |xargs rm -rf
find $DEFDIR -mtime +2 |xargs rm -rf
