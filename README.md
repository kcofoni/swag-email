# swag-email

This piece of code aims at extending the [linuxserver/swag images](https://github.com/linuxserver/docker-swag) by providing the ability to send email. The `swag-email` docker image add [msmtp](https://wiki.debian.org/msmtp) package to the underlying [alpine OS](https://www.alpinelinux.org/) and the related configuration files, as well as the way to test sending email.

The ability to send email is particularly useful for [fail2ban](https://www.fail2ban.org/wiki/index.php/Main_Page) for notifying events.

It can be used in a compose file as described below:

	---
	version: "2.1"
	services:
	  authelia:
	    image: authelia/authelia:latest
	    container_name: authelia
	    environment:
	      - TZ=Europe/Paris    
	    volumes:
	      - /home/docker/appdata/authelia/config:/config
	    restart: unless-stopped      
	  swag:
	    image: kcofoni/swag-mail
	    container_name: swag
	    cap_add:
	      - NET_ADMIN
	    environment:
	      - PUID=1000
	      - PGID=1000
	      - TZ=Europe/Paris
	      - URL=<your_domain>
	      - VALIDATION=dns
	      - SUBDOMAINS=wildcard
	      - DNSPLUGIN=ovh
	      - PROPAGATION=30
	      - STAGING=false
	      - EMAIL=<user>@<domain>
	      - DOCKER_MODS=linuxserver/mods:swag-dbip|linuxserver/mods:swag-dashboard
	    volumes:
	      - /home/docker/appdata/swag/config:/config
	    ports:
	      - 443:443
	    restart: unless-stopped

Before using the docker file for creating the image, please replace the content of */etc/msmtprc* by your data (*account/host/port/from*). Your secret (*user/password*) should be stored in a *.env* file. Please also customize contents of */etc/aliases* and */root/tests/...* files.
