domain=$1
root=$2

virtualenv_name='env'
wsgi_filename='wsgi.py'
static_alias="Alias /static $root/static

    <Directory $root/static>
            Require all granted
    </Directory>"


ssl_dir='/etc/letsencrypt/live'

while [ $# -gt 0 ]; do
    case "$1" in
        --wsgi)
        wsgi_filename=$4
        ;;
        --env)
        virtualenv_name=$4
        ;;
        --nostatic)
        static_alias=''
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

template="<VirtualHost *:80>
    ServerName $domain

    Redirect permanent / https://$domain
</VirtualHost>

<IfModule mod_ssl.c>
<VirtualHost *:443>
    ServerName $domain
    DocumentRoot $root

    WSGIDaemonProcess $domain python-home=$root/$virtualenv_name python-path=$root
    WSGIProcessGroup $domain
    WSGIScriptAlias / $root/$wsgi_filename process-group=$domain

    $static_alias

    <Directory $root>
        Require all granted
    </Directory>

    <IfModule mod_http2.c>
        Protocols h2 http/1.1
    </IfModule>

    SSLCertificateFile $ssl_dir/$domain/fullchain.pem
    SSLCertificateKeyFile $ssl_dir/$domain/privkey.pem
</VirtualHost>
</IfModule>"

echo "$template"
