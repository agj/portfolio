#!/usr/bin/env bash

TIME=$(date +%Y-%m-%d_%H-%M-%S)
REMOTE="$SSH_USER@$SSH_HOST"
REMOTE_CURRENT_BACKUP_DIR="$REMOTE_BACKUPS_DIR/$TIME"

echo
echo "Logging in to remote host $REMOTE on port $SSH_PORT"

echo
echo "Uploading to temporary directory $REMOTE_TEMP_DIR"
scp -P $SSH_PORT -r output "$REMOTE:$REMOTE_TEMP_DIR"

echo
echo "Moving old live files to backup directory $REMOTE_CURRENT_BACKUP_DIR"
ssh "$REMOTE" "-p$SSH_PORT" mkdir -p "$REMOTE_BACKUPS_DIR"
ssh "$REMOTE" "-p$SSH_PORT" mv "$REMOTE_DEPLOY_DIR" "$REMOTE_CURRENT_BACKUP_DIR"

echo
echo "Moving newly uploaded files to live directory $REMOTE_DEPLOY_DIR"
ssh "$REMOTE" "-p$SSH_PORT" mv "$REMOTE_TEMP_DIR" "$REMOTE_DEPLOY_DIR"
