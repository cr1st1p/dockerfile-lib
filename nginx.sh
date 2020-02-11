#shellcheck shell=bash

# Inspired from the official Dockerfile at https://github.com/nginxinc/docker-nginx/
# TODO: There is still place to improve

run_nginx_add_repo_debian_like() {

	assert_os_detected
	assert_os_code_name_dected

    enter_run_cmd


    cat << 'EOS'
    ; echo "NGINX SETUP" \
    ; NGINX_GPGKEY=573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	; found='' \
	; for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $NGINX_GPGKEY from $server"; \
		apt-key adv --no-tty --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$NGINX_GPGKEY" && found=yes && break; \
	done \
	; test -z "$found" && echo >&2 "error: failed to fetch GPG key $NGINX_GPGKEY" && exit 1 \
EOS

	cat << EOS	
    ; echo "deb https://nginx.org/packages/mainline/$os_id/ $os_code_name nginx" >> /etc/apt/sources.list.d/nginx.list \\
EOS
}


run_nginx_add_repo() {
	assert_os_detected

	if is_debian_like; then
		run_nginx_add_repo_debian_like
	else
		bail "nginx_add_repo: unhandled OS"
	fi
}


run_nginx_install() {
	if is_debian_like; then
    	cmd_apt_min_install nginx
	else
		bail "nginx_install: unhandled OS"
	fi

    cat << 'EOS'
    ; echo "forward request and error logs to docker log collector" \
    ; ln -sf /dev/stdout /var/log/nginx/access.log \
	; ln -sf /dev/stderr /var/log/nginx/error.log \
EOS
}


run_nginx_as_nginx_user() {
    enter_run_cmd
	
    cat << 'EOS'
    ; touch /var/run/nginx.pid \
    ; sed -i -E -e 's@^\s*user\s+.*;@@' /etc/nginx/nginx.conf \
    ; chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid \
EOS
}
