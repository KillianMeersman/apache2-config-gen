# apache2-config-gen
A collection of config generation scripts for Apache 2.

These scripts will output two vhosts (to stdout) for http and https.
Simply redirect the ouput to your configuration files.
```sh
wsgi.sh killianm.dev /srv/www/killianm.dev > /etc/apache2/sites-available/killianm.dev.conf
```

## Generation scripts
- serve.sh: Static file hosting
- proxy.sh: Reverse proxy to another port
- wsgi.sh: WSGI execution for Python servers

## Sample output
```sh
serve.sh killianm.dev /srv/www/killianm.dev
```
```xml
<VirtualHost *:80>
    ServerName killianm.dev

    Redirect permanent / https://killianm.dev
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName killianm.dev
    DocumentRoot /srv/www/killianm.dev

    <Directory /srv/www/killianm.dev>
        Require all granted
    </Directory>

    <IfModule mod_http2.c>
        Protocols h2 http/1.1
    </IfModule>

    SSLCertificateFile /etc/letsencrypt/live/killianm.dev/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/killianm.dev/privkey.pem
</VirtualHost>
</IfModule>
```
