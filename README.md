# Pi-hole Ad Blocker + Cloudflare Tunnel Client via Docker Compose

###### \* _credit goes to **apavamontri** for original code (see: https://github.com/apavamontri/pi-hole-cloudflared-docker)_ *

<br>

**BLUF**: This project will allow you to use [Docker Compose](https://docs.docker.com/compose/) to run [Pi-hole](https://pi-hole.net/) and [Cloudflare Tunnel Client](https://github.com/cloudflare/cloudflared) in tandem to achieve [DNS-Over-HTTPS](https://docs.pi-hole.net/guides/dns/cloudflared/). Not to mention domain-level ad blocking!

<br>

**NOTE**: If your use case is to block [YouTube](https://discourse.pi-hole.net/t/youtube-ads-getting-through-pihole-any-advances-in-100-blocking-without-also-blocking-youtube-videos/60951) or [Hulu](https://www.reddit.com/r/pihole/comments/lbzjyt/hulu_ads/?rdt=45152) ads... find another use case 😜.

<br>

# Requirements

* **Docker Compose or Docker Desktop** (Docker install scripts for [RHEL/CentOS Stream 8-9](./install-docker_rhel8-9.sh) and [Pi OS](./install-docker_pi-os.sh) included in this repo; I'll add Windows and MacOS... at some point)

* **Your pick of operating system, generally...** (_Windows_ installs will require WSL v1.2 or later) (Google Bard: "Docker currently supports the latest version of _macOS_ and the previous two releases. For example, at the time of writing, Docker supports macOS Monterey (latest), macOS Big Sur, and macOS Catalina.") (Most flavors of _Linux_ are supported, but Google is always your friend; I'm using CentOS Stream 9)

* Preferably at least 4GB of RAM (I mean, 2GB would probably be fine?)

* (OPTIONAL) [Cloudflare Zero Trust](https://www.cloudflare.com/zero-trust/products/access/) account for enhanced DNS capabilities

<br>

# Build Instructions

i. (OPTIONAL) Create/[log into](https://dash.cloudflare.com/login) your Cloudflare account and Navigate to **Zero Trust** from the lefthand menu. Expand _Gateway_ and select _DNS Locations_.

<br>

ii. (OPTIONAL) Click the blue **Add a location** button. Choose whichever name you'd like (this matters to no one but you), then click the _Add IP_ button; this should auto-populate with your current public address.

<br>

iii. (OPTIONAL) Check the _Set as Default DNS Location_ box and click _Add location_ in the bottom-right.

<br>

iv. (OPTIONAL) Click on your newly created location under the **Location name** menu. Under _Location details_, record the two **IPv4** addresses as well as the **DNS over HTTPS** URL. Save those three values for later. (Those IPv4 addresses are essentially your personal _1.1.1.1_ and _1.0.0.1_ with enhanced security options)

![image](https://github.com/dynamic-stall/pi-hole-cloudflared-docker/assets/76631795/84d1828c-74f8-425d-85e1-a1ee95368e61)

<br>

1. Make sure Docker is running by entering the following command in the terminal.

```bash
docker --version
```

It should return something like this

```text
Docker version 20.10.21, build baeda1f
```

<br>

2. You can change the configuration values of Pi-hole and Cloudflare Tunnel Client in the [docker-compose.yml](./docker-compose.yml) file. Port configs should generally be left as is, unless you have specific requirements based on your environment. IP address ranges can be left as is, as Docker will create the bridge network for you (check notes at the end of that file as well as the troubleshooting steps in one of the ```install-docker_*``` scripts for details on how to specify _existing_ external networks). I advise you leave the CONTAINER names as is; another script relies on them being named, "pihole" and "cloudflared." HOSTNAME changes will affect nothing but the joy in your heart.

   * Docker Pi-hole's [Environment Variables](https://github.com/pi-hole/docker-pi-hole/#environment-variables)
   * Cloudflare Tunnel Client's [Environment Variables](https://github.com/cloudflare/cloudflared/blob/master/cmd/cloudflared/proxydns/cmd.go)

<br>

3. To build the Docker containers, run [build-pihole.sh](./build-pihole.sh)

```bash
sudo ./build-pihole.sh
```

This bash script will:

   * Ask for your intended Web Admin password (the ```password.txt``` file is populated, used for the Docker build, then deleted for security).

   * Start Docker Compose (in daemon mode).

   * Build your containers to spec (successfully, one would hope).

<br>

4. Run the following command to to check basic stats of your newly erected containers:

```bash
docker container ls
```

If you see either container stuck in a ```Restarting``` state, something went wrong during the compose ("This looks like a job for..." you).

<br>

# Pi-hole Web Admin UI

Once the Pi-hole Docker container has started, you can access Pi-hole's Web Admin UI at [http://localhost:8061/admin](http://localhost:8061/admin).

![pi-hole-web-admin-home](https://github.com/dynamic-stall/pihole-cloudflared-docker/assets/76631795/80595882-7bb2-4b0f-aaff-5fd4f7b4623d)

<br>

Enter the Web Admin password you set earlier.

<br>

You can check the **Upstream DNS Servers** by navigating to _Settings_ from the lefthand menu and selecting the DNS tab. You should see the IP address set for your Cloudflare Tunnel Client under **Custom 1 (IPv4)**.

![d-room dns scrnshot-markup](https://github.com/dynamic-stall/pihole-cloudflared-docker/assets/76631795/e45c3a88-f66d-4a02-8e60-e1743f7ac9d7)

<br>

# Network Configuration

This last and most important step depends on your network setup and deployment strategy, really...

* Follow this [guide on DHCP configurations](https://docs.pi-hole.net/docker/dhcp/) for your containers. If deploying network-wide, this will be crucial.

   * _\*\* I reccommend going with a [macvlan network](https://tonylawrence.com/posts/unix/synology/free-your-synology-ports/) setup (dedicated IP for router DNS configs + no need for Pi-hole host port forwarding)_.
      * _(I'll update the ```docker-compose.yml``` template to reflect this... at some point)_

* Follow this [detailed guide on configuring your DNS](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245).

* Follow this [post-install guide](https://docs.pi-hole.net/main/post-install/) for additional guidance.

<br>

* **NOTE** If you have your Pi-hole container up and running, but Cloudflared is still misbehaving, you can deploy the Pi-hole container on its own: simply change the DNS servers Pi-hole is using under _Settings_ (see: **Pi-hole Web Admin UI** section). Set the two custom IPv4 addresses to the Cloudflare DNS addresses you recorded earlier \<OR\> use one of the preset DNS locations (I'd still recommend choosing Cloudflare's _1.1.1.1_, if nothing else...).
