# Pi-hole and Cloudflare Tunnel Client Using Docker Compose

###### \* _credit goes to **apavamontri** for original code (see: https://github.com/apavamontri/pi-hole-cloudflared-docker)_ *
<br><br>
BLUF: This project will allow you to use [Docker Compose](https://docs.docker.com/compose/) to run [Pi-hole](https://pi-hole.net/) and [Cloudflare Tunnel Client](https://github.com/cloudflare/cloudflared) together to achieve [DNS-Over-HTTPS](https://docs.pi-hole.net/guides/dns/cloudflared/). Not to mention domain-level ad blocking!

# Requirements

- Whichever flavor of Linux you feel like troubleshooting (I'm using CentOS Stream 9)
- Docker Compose or Docker Desktop (version 4.4x or later) (_if you're installing on a similar OS, [I gotchu](https://tecadmin.net/how-to-install-docker-on-centos-stream-9/)_)
- [Cloudflare Zero Trust](https://www.cloudflare.com/zero-trust/products/access/) account for enhanced DNS capabilities (OPTIONAL)

# Instructions

1. In `./web-password` directory, rename `password.sample.txt` to `password.txt`.

2. Change the content of `password.txt` file to set a password for Pi-hole's administrative UI.

3. (OPTIONAL) Create/[log into](https://dash.cloudflare.com/login) your Cloudflare account and Navigate to **Zero Trust** from the lefthand menu. Expand _Gateway_ and select _DNS Locations_.

4. (OPTIONAL) Click the blue **Add a location** button. Choose whichever name you'd like (this matters to no one but you), then click the _Add IP_ button; this should auto-populate with your current public address.

5. (OPTIONAL) Check the _Set as Default DNS Location_ box and click _Add location_ in the bottom-right.

6. (OPTIONAL) Click on your newly created location under the **Location name** menu. Under _Location details_, record the two **IPv4** addresses as well as the **DNS over HTTPS** URL. Save those three values for later. (Those IPv4 aadresses are essentially your personal _1.1.1.1_ and _1.0.0.1_ with enhanced security options)

![image](https://github.com/dynamic-stall/pi-hole-cloudflared-docker/assets/76631795/84d1828c-74f8-425d-85e1-a1ee95368e61)

7. Make sure Docker Desktop is running by running the following command in the terminal.

```bash
docker --version
```

It should return something like this

```text
Docker version 20.10.21, build baeda1f
```

8. You can change the configuration values of Pi-hole and Cloudflare Tunnel Client in the [docker-compose.yml](./docker-compose.yml) file.

   - Docker Pi-Hole's [Environment Variables](https://github.com/pi-hole/docker-pi-hole/#environment-variables)
   - Cloudflare Tunnel Client's [Environment Variables](https://github.com/cloudflare/cloudflared/blob/master/cmd/cloudflared/proxydns/cmd.go)

9. To start run [start-pihole.sh](./start-pihole.sh)

```bash
sudo ./start-pihole.sh
```

This bash script will:

a. Start Docker Compose in detached mode.
~~b. Clear the WiFi DNS server~~
~~c. Set the WiFi DNS server to localhost (`127.0.0.1`) which Pi-hole will run on TCP port `53`~~

# ~~Stop Docker Compose and Reset WiFi DNS~~

~~Run [stop-pihole.sh](./stop-pihole.sh)~~

```bash
sudo ./stop-pihole.sh
```

# Pi-hole Web Admin

Once the Pi-hole docker started, you can access Pi-hole's web admin UI at [http://localhost:8061/admin](http://localhost:8061/admin).

![pi-hole-web-admin-homepage](./doc/images/pi-hole-web-admin-home.png)

Enter a password you set in `./web-password/password.txt` file.

You can check the [Upstream DNS Serves](http://localhost:8061/admin/settings.php?tab=dns) settings and you should see it set to Cloudflare Tunnel Client.

![pi-hole-web-admin-dns-upstream](./doc/images/pi-hole-web-admin-dns-upstream.png)
