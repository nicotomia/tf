server {
    root /var/www/wordpress;
    index index.php index.html index.htm;
    server_name terraform.devops-alumno02.com;

    access_log /var/log/nginx/subdominio_access.log;
    error_log /var/log/nginx/subdominio_error.log;

    client_max_body_size 64M;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;
        include /etc/nginx/fastcgi_params;
        fastcgi_read_timeout 3600s;
        fastcgi_buffer_size 128k;
        fastcgi_buffers 4 128k;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php7.3-fpm.sock;
        fastcgi_index index.php;
        fastcgi_hide_header X-Powered-By;
        proxy_hide_header X-Powered-By;
    }

    location ~* /xmlrpc.php$ {
        allow 172.0.1.1;
        deny all;
    }

    if ($request_method !~ ^(GET|POST)$ ) {
        return 444;
    }

    location ~* /(?:uploads|files|wp-content|wp-includes|akismet)/.*.php$ {
        deny all;
        access_log off;
        log_not_found off;
    }
    
    location ~ /\.(svn|git)/* {
        deny all;
        access_log off;
        log_not_found off;
    }
    location ~ /\.ht {
        deny all;
        access_log off;
        log_not_found off;
    }
    location ~ /\.user.ini { 
        deny all; 
        access_log off;
        log_not_found off;
    }
