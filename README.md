# Pi-hole and Cloudflare Tunnel Client Using Docker Compose

###### \* _credit goes to **apavamontri** for original code (see: https://github.com/apavamontri/pi-hole-cloudflared-docker)_ *
<br><br>
BLUF: This project will allow you to use [Docker Compose](https://docs.docker.com/compose/) to run [Pi-hole](https://pi-hole.net/) and [Cloudflare Tunnel Client](https://github.com/cloudflare/cloudflared) together to achieve [DNS-Over-HTTPS](https://docs.pi-hole.net/guides/dns/cloudflared/). Not to mention domain-level ad blocking!

# Requirements

- Whichever flavor of Linux you feel like troubleshooting (I'm using CentOS Stream 9)
- Docker Compose or Docker Desktop (Docker install scripts for [RHEL/CentOS Stream 8-9](./install-docker_rhel8-9.sh) and [Pi OS](./install-docker_pi-os.sh) included in this repo)
- (OPTIONAL) [Cloudflare Zero Trust](https://www.cloudflare.com/zero-trust/products/access/) account for enhanced DNS capabilities

# Instructions

1. (OPTIONAL) Create/[log into](https://dash.cloudflare.com/login) your Cloudflare account and Navigate to **Zero Trust** from the lefthand menu. Expand _Gateway_ and select _DNS Locations_.

2. (OPTIONAL) Click the blue **Add a location** button. Choose whichever name you'd like (this matters to no one but you), then click the _Add IP_ button; this should auto-populate with your current public address.

3. (OPTIONAL) Check the _Set as Default DNS Location_ box and click _Add location_ in the bottom-right.

4. (OPTIONAL) Click on your newly created location under the **Location name** menu. Under _Location details_, record the two **IPv4** addresses as well as the **DNS over HTTPS** URL. Save those three values for later. (Those IPv4 aadresses are essentially your personal _1.1.1.1_ and _1.0.0.1_ with enhanced security options)

![image](https://github.com/dynamic-stall/pi-hole-cloudflared-docker/assets/76631795/84d1828c-74f8-425d-85e1-a1ee95368e61)

5. Make sure Docker Desktop is running by running the following command in the terminal.

```bash
docker --version
```

It should return something like this

```text
Docker version 20.10.21, build baeda1f
```

6. You can change the configuration values of Pi-hole and Cloudflare Tunnel Client in the [compose.yml](./compose.yml) file.

   - Docker Pi-Hole's [Environment Variables](https://github.com/pi-hole/docker-pi-hole/#environment-variables)
   - Cloudflare Tunnel Client's [Environment Variables](https://github.com/cloudflare/cloudflared/blob/master/cmd/cloudflared/proxydns/cmd.go)

7. To build the Docker containers, run [build-pihole.sh](./build-pihole.sh)

```bash
sudo ./build-pihole.sh
```

This bash script will:

a. Ask for your intended Web Admin password (the ```password.txt``` file is populated, used for the Docker build, then deleted for security).

b. Start Docker Compose in detached mode.

c. Build your containers to spec (successfully, one would hope).

# Pi-hole Web Admin UI

Once the Pi-hole Docker container has started, you can access Pi-hole's Web Admin UI at [http://localhost:8061/admin](http://localhost:8061/admin).

![pi-hole-web-admin-homepage](./doc/images/pi-hole-web-admin-home.png)

Enter the Web Admin password you set earlier.

You can check the [Upstream DNS Servers](http://localhost:8061/admin/settings.php?tab=dns) by navigating to _Settings_ on the lefthand side and selecting the DNS tab. You should see the IP address set for your Cloudflare Tunnel Client under **Custom 1 (IPv4)**.

![d-room dns scrnshot](https://github.com/dynamic-stall/pihole-cloudflared-docker/assets/76631795/f6da72be-f1d9-491b-91c9-7954633d05c4)
