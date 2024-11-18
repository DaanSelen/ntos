#!/bin/bash

echo "Searching for pre-installed apache2 or nginx webserver application..."

check_installed_webserver() {
	apache_installed=$(dpkg --get-selections | grep apache2 | cut -f1)
	nginx_installed=$(dpkg --get-selections | grep nginx | cut -f1)

	if [ -z "$apache_installed" ]; then
                echo "Apache2 is not installed"
		preflight_check=0
        else
                echo "Apache2 looks to be installed"
		preflight_check=1

                printf "What is the directory to place HTML files? (Default: /var/www/html/) "
                read -r custom_path

                if [ -z $custom_path ]; then
                        web_file_path="/var/www/html/"
                else
                        web_file_path="$custom_path"
                fi
        fi

        if [ -z "$nginx_installed" ]; then
                echo "NGINX is not installed"
		preflight_check=0
        else
                echo "NGINX looks to be installed"
		preflight_check=1

                printf "What is the directory to place HTML files? (Default: /usr/share/nginx/html/) "
                read -r custom_path

                if [ -z "$custom_path" ]; then
                        web_file_path="/usr/share/nginx/html/"
                else
                        web_file_path="$custom_path"
                fi
        fi
}

setup_ntos_files() {
	if [ $"preflight_check" -eq 1 ]; then
		echo "Copying files to their respective places..."
		cp 
}

main() {
	check_installed_webserver
	echo $web_file_path
	setup_ntos_files
}

main

echo "Exiting"
exit 0
