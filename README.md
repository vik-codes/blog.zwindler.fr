# blog.zwindler.fr

## Prerequisites on a Ubuntu fresh server

Install prerequisites

```
sudo apt update && sudo apt upgrade
sudo reboot
```

Install a bunch of things

```
sudo apt install nginx git golang-go certbot python3-certbot-nginx
```

Install hugo

```
wget https://github.com/gohugoio/hugo/releases/download/v0.139.2/hugo_extended_0.139.2_linux-amd64.deb
sudo apt install ./hugo_extended_0.139.2_linux-amd64.deb 
```

Generate an SSH key for git pulling the sources (RO)

```
ssh-keygen -t ed25519 -C "blog@zwindler.fr"
chmod 600 /root/.ssh/id_ed25519
sudo mkdir /var/www/.ssh/
sudo cp ~/.ssh/id_ed25519* /var/www/.ssh/
chown www-data: /var/www/.ssh/*
```

Also git clone (as another user) to accept github ssh host key, and copy the known_hosts to www-data .ssh directory to avoid issues with the script launched by "webhook" later

```
cp /root/.ssh/known_hosts /var/www/.ssh/known_hosts
```

Copy public key in github repository (as deploy key)

## Get blog sources on server

```
cd /usr/share/nginx/html
GIT_SSH_COMMAND='ssh -i /var/www/.ssh/id_ed25519 -o IdentitiesOnly=yes' git clone git@github.com:zwindler/blog.zwindler.fr
cd blog.zwindler.fr/
chown -R www-data: /usr/share/nginx/html/blog.zwindler.fr/
```

Tell git this directory is ok

```
git config --global --add safe.directory /usr/share/nginx/html/blog.zwindler.fr
```

## Webhook installation
```
cd /root
export VERSION="2.8.2"
wget https://github.com/adnanh/webhook/releases/download/${VERSION}/webhook-linux-amd64.tar.gz
tar -xvf webhook*.tar.gz
sudo mv webhook-linux-amd64/webhook /usr/local/bin
rm -rf webhook-linux-amd64*
webhook --version
```

```
WHSECRET=`uuidgen | base64`
mkdir /etc/webhook
cat > /etc/webhook/hook.json << EOF
[
    {
        "id": "redeploy",
        "execute-command": "/usr/share/nginx/html/blog.zwindler.fr/blog_refresh.sh",
        "command-working-directory": "/usr/share/nginx/html/blog.zwindler.fr",
        "trigger-rule":
        {
            "match":
            {
                "type": "payload-hmac-sha1",
                "secret": "$WHSECRET",
                "parameter":
                {
                    "source": "header",
                    "name": "X-Hub-Signature"
                }
            }
        }
    }
]
EOF
```

Check file 

```
cat /etc/webhook/hook.json 
```

Create systemd service

```
cat > /etc/systemd/system/webhook.service << EOF
[Unit]
Description=Simple Golang webhook server
ConditionPathExists=/usr/local/bin/webhook
After=network.target

[Service]
User=www-data
Group=www-data
Type=simple
WorkingDirectory=/usr/share/nginx/html/blog.zwindler.fr
ExecStart=/usr/local/bin/webhook -ip 127.0.0.1 -hooks /etc/webhook/hook.json -verbose
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl enable webhook
systemctl start webhook
```

## nginx configuration

Create a basic configuration file

```
cat > /etc/nginx/sites-available/blog.zwindler.fr.conf << EOF
# Root configuration
server {
  listen 80;
  server_name blog.zwindler.fr;

  location /hooks/ {
    proxy_pass http://127.0.0.1:9000/hooks/;
  }

  error_page 404 /404.html;

  location / {
    root /usr/share/nginx/html/blog.zwindler.fr/public;
    index index.html;
  }
}
EOF

ln -s /etc/nginx/sites-{available,enabled}/blog.zwindler.fr.conf
```

Check nginx configuration

```
nginx -t
```

Try to add a certificate (DNS should already point on the ubuntu server for this to work)

```
certbot --nginx
```

## Generate preview

```bash
hugo server
```

## Generate static files

```bash
hugo
```

Static files are available in `public/` directory
