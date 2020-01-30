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

# Generate DHE key
if [ -z /etc/ssl/certsdhparam.pem ]; then
	openssl dhparam -out /etc/ssl/certsdhparam.pem 4096
fi

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
		SSLCompression off
		SSLProtocol -all +TLSv1.3 +TLSv1.2
    	SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4
    	SSLHonorCipherOrder on
		SSLOpenSSLConfCmd Curves X25519:secp521r1:secp384r1:prime256v1
		SSLOpenSSLConfCmd DHParameters '/etc/ssl/certs/dhparam.pem'

		LoadModule headers_module modules/mod_headers.so
		Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains;"
		Header always set X-Frame-Options DENY
	</VirtualHost>
</IfModule>"

echo "$template"
