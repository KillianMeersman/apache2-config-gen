DOMAIN=$1
ROOT=$2

VIRTUALENV_NAME='env'
WSGI_FILENAME='wsgi.py'
STATIC_ALIAS="Alias /static $ROOT/static"


LE_DIR='/etc/letsencrypt/live'

AUTH=''

while [ $# -gt 2 ]; do
    case "$3" in
        --wsgi)
        WSGI_FILENAME=$4
        ;;
        --env)
        VIRTUALENV_NAME=$4
        ;;
        --nostatic)
        STATIC_ALIAS=''
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

    SSLCertificateFile $LE_DIR/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile $LE_DIR/$DOMAIN/privkey.pem
</VirtualHost>
</IfModule>"

echo "$TEMPLATE"
