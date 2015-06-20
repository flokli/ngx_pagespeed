FROM ubuntu:precise
MAINTAINER Florian Klink <flokli@flokli.de>

ENV NGINX_VERSION 1.8.0
ENV NPS_VERSION 1.9.32.4

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# Fix locales
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Install build tools for nginx
RUN apt-get update && \
    apt-get build-dep -y nginx-full && \
    apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip wget ca-certificates

RUN wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
    unzip release-${NPS_VERSION}-beta.zip && \
    cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    tar -xzvf ${NPS_VERSION}.tar.gz  

RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION}/ && \
    ./configure \
	--prefix=/usr \
	--conf-path=/etc/nginx/nginx.conf \
	--error-log-path=/var/log/nginx/error.log \
	--sbin-path=/usr/sbin/nginx \	
	--http-log-path=/var/log/nginx/access.log \
	--pid-path=/run/nginx.pid \
	--lock-path=/run/lock/nginx.lock \
	--with-ipv6 \
	--with-pcre \
	--with-http_realip_module \
	--with-http_ssl_module \
	--with-http_addition_module \
	--with-http_sub_module \
	--with-http_gunzip_module \
	--with-http_gzip_static_module \
	--with-http_random_index_module \
	--with-http_secure_link_module \
	--with-http_stub_status_module \
	--with-http_spdy_module \
	--with-sha1=/usr/include/openssl \
 	--with-md5=/usr/include/openssl \
	--add-module=../ngx_pagespeed-release-${NPS_VERSION}-beta && \
    make && \
    make install && \
    cd .. && \
    rm -R release-${NPS_VERSION}-beta.zip ngx_pagespeed-release-${NPS_VERSION}-beta/ nginx-${NGINX_VERSION}.tar.gz nginx-${NGINX_VERSION}

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]
