server {
    listen 80;
    server_name other.rodrigonginx.com;

    root /var/www/other.rodrigonginx.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
