DOMAIN=$1
PORT=$2

LE_DIR='/etc/letsencrypt/live'

AUTH=''

while [ $# -gt 0 ]; do
    case "$1" in
        -a|--auth)
            AUTH="
			AuthType Basic
			AuthName 'Authentication required'
			AuthUserFile /etc/apache2/.htpasswd
			Require valid-user"
        	;;
		-h|--help)
			echo "
Generate a reverse proxy configuration file

Usage: proxy.sh <domain> <port>
Flags:
	-a, --auth: Add basic authentication"
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
	
		ProxyPass / http://127.0.0.1:$PORT/
		ProxyPassReverse / http://127.0.0.1:$PORT/

		<Location />
			Require all granted$AUTH
		</Location>

		<IfModule mod_http2.c>
			Protocols h2 http/1.1
		</IfModule>
		
		SSLCertificateFile $LE_DIR/$DOMAIN/fullchain.pem
		SSLCertificateKeyFile $LE_DIR/$DOMAIN/privkey.pem
	</VirtualHost>
</IfModule>"

echo "$TEMPLATE"
