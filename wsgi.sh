DOMAIN=$1
ROOT=$2

VIRTUALENV_NAME='env'
WSGI_FILENAME='wsgi.py'
STATIC_ALIAS="Alias /static $ROOT/static

    <Directory $ROOT/static>
            Require all granted
    </Directory>"


LE_DIR='/etc/letsencrypt/live'

AUTH=''

while [ $# -gt 0 ]; do
    case "$1" in
        --wsgi)
        WSGI_FILENAME=$4
        ;;
        --env)
        VIRTUALENV_NAME=$4
        ;;
        --nostatic)
        STATIC_ALIAS=''
        ;;
		-h|--help)
			echo "
Generate a wsgi configuration file

Usage: wsgi.sh <domain> <documentRoot>
Flags:
    --wsgi: Set wsgi filepath relative to the documentRoot
    --env: Set the environment folder relative to the documentRoot
    --nostatic: Don't add the static alias directive"
			exit 0
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

    WSGIDaemonProcess $DOMAIN python-home=$ROOT/$VIRTUALENV_NAME python-path=$ROOT
    WSGIProcessGroup $DOMAIN
    WSGIScriptAlias / $ROOT/$WSGI_FILENAME process-group=$DOMAIN

    $STATIC_ALIAS

    <Directory $ROOT>
        Require all granted
    </Directory>

    <IfModule mod_http2.c>
        Protocols h2 http/1.1
    </IfModule>

    SSLCertificateFile $LE_DIR/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile $LE_DIR/$DOMAIN/privkey.pem
</VirtualHost>
</IfModule>"

echo "$TEMPLATE"
