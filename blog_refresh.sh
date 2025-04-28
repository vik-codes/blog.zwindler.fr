#!/bin/bash
cd /usr/share/nginx/html/blog.zwindler.fr

#pull latest version
GIT_SSH_COMMAND='ssh -i /var/www/.ssh/id_ed25519 -o IdentitiesOnly=yes' git pull git@github.com:zwindler/blog.zwindler.fr.git

#rebuild (fire and forget)
hugo --minify --gc &
