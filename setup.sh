#!/bin/bash

echo "Searching for pre-installed apache2 or nginx webserver application..."

_check_rdp_profiles() {
        if [ "$(find "./ntos/rdp" -maxdepth 1 -type f -name "*.rdp" | wc -l)" -gt 0 ]; then
                echo "Found one or more .rdp files in ./ntos/rdp"
                ls "./ntos/rdp"/*.rdp
        else
                echo "No .rdp files found in ./ntos/rdp"
        fi
}

_check_installed_webserver() {
	apache_installed=$(dpkg --get-selections | grep apache2 | cut -f1)
	nginx_installed=$(dpkg --get-selections | grep nginx | cut -f1)

	if [ -z "$apache_installed" ]; then
		preflight_check=0
        else
                echo 'Apache2 looks to in an installed state'
                printf 'What is the directory to place HTML files? (Default: /var/www/html/) '
                read -r custom_path
                preflight_check=1

                if [ -z "$custom_path" ]; then
                        web_file_path='/var/www/html/'
                else
                        web_file_path="$custom_path"
                fi
                return
        fi

        if [ -z "$nginx_installed" ]; then
		preflight_check=0
        else
                echo 'NGINX looks to in an installed state'
                printf 'What is the directory to place HTML files? (Default: /usr/share/nginx/html/) '
                read -r custom_path
                preflight_check=1

                if [ -z "$custom_path" ]; then
                        web_file_path='/usr/share/nginx/html/'
                else
                        web_file_path="$custom_path"
                fi
                return
        fi

        if [ "$preflight_check" -eq 0 ]; then
                printf 'No Apache2 or NGINX installation found. Do you want this script to install it? (It will install Apache2) (y/N) '
                read -r user_granted_install_permission
                if [[ "$user_granted_install_permission" =~ ^[yY]$ ]]; then
                        install_apache2_webserver
                        return
                fi

                printf 'Do you want to specify a custom HTML directory? (y/N) '
                read -r user_wants_custom

                if [[ "$user_wants_custom" =~ ^[yY]$ ]]; then
                        printf 'What should the custom location be? Enter: '
                        read -r web_file_path
                        preflight_check=1
                else
                        echo 'Please install either Apache2 or NGINX first, and then rerun this.'
                        exit 0
                fi
        fi
                
}

_check_user_perms() {
        if [ "$(id -u)" -eq 0 ]; then
                return
        else
                echo 'Insufficient privileges.'
                exit 1
        fi

}

install_apache2_webserver() {
        echo 'Installing apache2...'

        _check_user_perms
        apt install -y apache2 &> /dev/null

        _check_installed_webserver
}

copy_ntos_files() {
	echo "Copying files to their respective places..."

        if [ -w "$web_file_path" ]; then
	        cp -rv ./ntos/* "$web_file_path"
        else
                _check_user_perms
        fi
        echo "Done copying."
}

main() {
        _check_rdp_profiles
	_check_installed_webserver
	echo "Chosen HTML-filepath is: ${web_file_path}"

        if [ "$preflight_check" -eq 1 ]; then
                copy_ntos_files
        else
                echo "Something is missing"
                exit 1
        fi

        echo "Succesfully installed."
}

main
