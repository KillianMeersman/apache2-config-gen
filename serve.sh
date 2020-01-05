DOMAIN=$1
ROOT=$2

LE_DIR='/etc/letsencrypt/live'

AUTH=''

while [ $# -gt 2 ]; do
    case "$3" in
        -a|--auth)
            AUTH="
        AuthType Basic
        AuthName 'Authentication required'
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user"
        ;;
    esac
    shift
done

TEMPLATE="<VirtualHost *:80>
    ServerName $DOMAIN

    Redirect permanent / https://$DOMAIN
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot $ROOT

    <Directory $ROOT>
        Require all granted$AUTH
    </Directory>

    <IfModule mod_http2.c>
        Protocols h2 http/1.1
    </IfModule>

    SSLCertificateFile $LE_DIR/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile $LE_DIR/$DOMAIN/privkey.pem
</VirtualHost>
</IfModule>"

echo "$TEMPLATE"
