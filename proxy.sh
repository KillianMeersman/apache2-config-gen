domain=$1
port=$2

ssl_dir='/etc/letsencrypt/live'

auth=''

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
Generate a reverse proxy configuration file

Usage: proxy.sh <domain> <port>
Flags:
	-a, --auth: Add basic authentication"
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
	
		ProxyPass / http://127.0.0.1:$port/
		ProxyPassReverse / http://127.0.0.1:$port/

		<Location />
			Require all granted$auth
		</Location>

		<IfModule mod_http2.c>
			Protocols h2 http/1.1
		</IfModule>
		
		SSLCertificateFile $ssl_dir/$domain/fullchain.pem
		SSLCertificateKeyFile $ssl_dir/$domain/privkey.pem
	</VirtualHost>
</IfModule>"

echo "$template"
