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
