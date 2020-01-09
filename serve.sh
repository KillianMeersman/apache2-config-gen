domain=$1
root=$2

ssl_dir='/etc/letsencrypt/live'

auth=''
fallback=''

while [ $# -gt 0 ]; do
    case "$1" in
        -a|--auth)
            auth="
        AuthType Basic
        AuthName 'Authentication required'
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user"
        ;;

		-h|--help)
			echo "
Generate a static webserver configuration file

Usage: serve.sh <domain> <documentRoot>
Flags:
    -a, --auth: Add basic authentication
    --fallback: Add a global fallback for single page applications using HTML5 history mode routing"
			exit 0
			;;

        --fallback)
        index='/index.html'
        if [ ! -z $4 ]; then
            index="$4"
        fi
        fallback="
    FallbackResource $index
        "
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
    $fallback
    <Directory $root>
        Require all granted$auth
    </Directory>

    <IfModule mod_http2.c>
        Protocols h2 http/1.1
    </IfModule>

    SSLCertificateFile $ssl_dir/$domain/fullchain.pem
    SSLCertificateKeyFile $ssl_dir/$domain/privkey.pem
</VirtualHost>
</IfModule>"

echo "$template"
