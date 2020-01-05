DOMAIN=$1
ROOT=$2

VIRTUALENV_NAME='env'
WSGI_FILENAME='wsgi.py'


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

    <Directory $ROOT>
        Require all granted
        <Files $WSGI_FILENAME>
            Require all denied
        </Files>
    </Directory>

    SSLCertificateFile $LE_DIR/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile $LE_DIR/$DOMAIN/privkey.pem
</VirtualHost>
</IfModule>"

echo "$TEMPLATE"
