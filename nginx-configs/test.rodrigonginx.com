server {
    listen 80;
    server_name test.rodrigonginx.com;

    root /var/www/test.rodrigonginx.com;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}
