#!/bin/bash

current_date=$(date +”%Y-%m-%d”)
backup_dir=”/opt/backups”
backup_file=”server-backup-$current_date.tar.gz”
source_dir=”/etc/frr/frr.conf”

mkdir -p “$backup_dir”
tar -czvf “$backup_dir/$backup_file” “$source_dir”
echo “BACKUP $source_dir COMPLETE: $backup_file”
