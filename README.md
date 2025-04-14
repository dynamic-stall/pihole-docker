# Pi-hole Ad Blocker with Cloudflare Proxy DNS

<br>

**BLUF**: This project will allow you to use [Docker Compose](https://docs.docker.com/compose/) to run [Pi-hole](https://pi-hole.net/) and [Cloudflare Tunnel Client](https://github.com/cloudflare/cloudflared) in tandem to achieve [DNS-Over-HTTPS](https://docs.pi-hole.net/guides/dns/cloudflared/). Not to mention network-level ad blocking!

<br>

**NOTE**: If your use case is to block [YouTube](https://discourse.pi-hole.net/t/youtube-ads-getting-through-pihole-any-advances-in-100-blocking-without-also-blocking-youtube-videos/60951) or [Hulu](https://www.reddit.com/r/pihole/comments/lbzjyt/hulu_ads/?rdt=45152) ads... find another use case 😜.

<br>

**DISCLAIMER**: This is an educational experience aimed at deepening one's understanding of networking and containerization. Pi-hole is open-source software licensed under the European Union Public License (EUPL), which allows for its free use and modification. Please refer to [this link](https://pi-hole.net/trademark-rules-and-brand-guidelines/) for trademark rules and brand guidelines. As always, use your best judgement and/or [the Internet](https://www.reddit.com/r/pihole/comments/a6q2zv/are_there_any_legal_concerns_in_the_us_for_using/?rdt=44519) for guidelines on things you should and should not be doing with this software.

<br>

## Requirements

* **Docker Compose or Docker Desktop** (Docker install scripts for [RHEL/CentOS Stream 8-9](./install-docker_rhel8-9.sh), [Pi OS](./install-docker_pi-os.sh), and [macOS](./install-docker_macos.sh) included in this repo)

* **Your pick of operating system, generally...** (_Windows_ installs will require WSL v1.2 or later) (_macOS_ version 10.13 -- High Sierra -- and newer is what ChatGPT and Google Gemini reccommend) (Most flavors of _Linux_ are supported, but Google is always your friend; I'm using CentOS Stream 9)

* Preferably at least 4GB of RAM (2GB _might_ work, but you likely won't be happy with it)

* (OPTIONAL) [Cloudflare Zero Trust](https://www.cloudflare.com/zero-trust/products/access/) account for enhanced DNS capabilities

<br>

## Build Instructions

i. (OPTIONAL) Create/[log into](https://dash.cloudflare.com/login) your Cloudflare account and Navigate to **Zero Trust** from the lefthand menu. Expand _Gateway_ and select _DNS Locations_.

<br>

ii. (OPTIONAL) Click the blue **Add a location** button. Choose whichever name you'd like (this matters to no one but you), then click the _Add IP_ button; this should auto-populate with your current public address.

<br>

iii. (OPTIONAL) Check the _Set as Default DNS Location_ box and click _Add location_ in the bottom-right.

<br>

iv. (OPTIONAL) Click on your newly created location under the **Location name** menu. Under _Location details_, record the two **IPv4** addresses as well as the **DNS over HTTPS** URL. Save those three values for later. (Those IPv4 addresses are essentially your personal _1.1.1.1_ and _1.0.0.1_ with enhanced security options)

![cf-zerotrust gateway tutorial 1](https://github.com/user-attachments/assets/d543bdd3-a01e-4d81-844b-ab1543b02a5d)

<br>

1. Clone this repository:
```bash
git clone https://github.com/dynamic-stall/pihole-docker
cd pihole-docker
```

<br>

2. Create a `.env` from the `example` file (_be sure to add your personalized variables_):
```bash
cp .env.example .env
```
<br>

3. You can change the configuration values of Pi-hole and Cloudflare Tunnel Client in the [docker-compose.yml](./docker-compose.yml) file. Port configs should generally be left as is, unless you have specific requirements based on your environment. IP address ranges can be left as is, as Docker will create the bridge network for you (check notes at the end of that file as well as the troubleshooting steps in one of the ```install-docker_*``` scripts for details on how to specify _existing_ external networks). I advise you leave the CONTAINER names as is; another script relies on them being named, "pihole" and "cloudflared." HOSTNAME changes will affect nothing but the joy in your heart.

   * Docker Pi-hole's [Environment Variables](https://github.com/pi-hole/docker-pi-hole/#environment-variables)
   * Cloudflare Tunnel Client's [Environment Variables](https://github.com/cloudflare/cloudflared/blob/master/cmd/cloudflared/proxydns/cmd.go)

<br>

4. To create the directories for the Docker volumes, set your Pi-hole password, and build the Docker containers, run [build-pihole.sh](./build-pihole.sh):

```bash
sudo ./build-pihole.sh
```

This bash script will:

   * Create your local directories -- and set permissions -- for the Pi-hole container (if not already set up)

   * Establish a Docker group for the current user (if one hasn't been created already)

   * Start Docker Compose (in daemon mode)

   * Build your containers to spec (successfully, one would hope)

   * Set your Pi-hole password (no password file needed... who wants a plaintext file with sensitive info lying around?)

   * Display the containers created and their current status via `docker ps` command

<br>

If you see either container stuck in a ```Restarting``` state, something went wrong during the build; chances are, it's related to your volume directories (permissions or their very existence). You can also try restarting either stuck container (or re-composing) as a troubleshooting step:

```bash
docker restart <container-name>
```

\<OR\>

```bash
docker compose up -d
```

If the `restarting` status persists, take a look at your volume directories (default: `/srv/docker/pihole/`). Ensure that ownership is set to `root:docker` and that you have at least `read` and `execute` permissions. The script sets them to `770` (a.k.a. `rwxrwx---`) by default. Also ensure that your current user has access to the `docker` group (which the [build-pihole.sh](./build-pihole.sh) script takes care of). 

<br>

## Pi-hole Web Admin UI

Once the Pi-hole Docker container has started, you can access Pi-hole's Web Admin UI at [http://localhost:8061/admin](http://localhost:8061/admin).

![pi-hole-web-admin-home](https://github.com/dynamic-stall/pihole-cloudflared-docker/assets/76631795/80595882-7bb2-4b0f-aaff-5fd4f7b4623d)

<br>

Enter the Web Admin password you set earlier.

<br>

_If the password needs to be reset, run the following command:_

```bash
docker exec <pihole-container-name> pihole setpassword
```

* _(Entering a blank password will remove the password requirement altogether.)_

<br>

You can check the **Upstream DNS Servers** by navigating to _Settings_ from the lefthand menu and selecting the DNS tab. You should see the IP address set for your Cloudflare Tunnel Client under **Custom DNS Servers**.

![pihole-dash-dns-settings](https://github.com/user-attachments/assets/3081a642-5fce-44bf-adc6-c3c005dfa603)

<br>

## Network Configuration

This last and most important step depends on your network setup and deployment strategy.

* Follow this [guide on DHCP configurations](https://docs.pi-hole.net/docker/dhcp/) for your containers. If deploying network-wide, this will be crucial.

   * _\*\* I recommend going with a [macvlan network](https://tonylawrence.com/posts/unix/synology/free-your-synology-ports/) setup (dedicated IP for router DNS configs + no need for Pi-hole host port forwarding)_.
      * _(See instructions in the [custom-network.sh](./custom-network.sh) file for additional detail on setting this up)_

* Follow this [detailed guide on configuring your DNS](https://discourse.pi-hole.net/t/how-do-i-configure-my-devices-to-use-pi-hole-as-their-dns-server/245).

* Follow this [post-install guide](https://docs.pi-hole.net/main/post-install/) for additional guidance.

<br>

* **NOTE**: If you have your Pi-hole container up and running, but Cloudflared is still misbehaving, you can deploy the Pi-hole container on its own: simply change the DNS servers Pi-hole is using under _Settings_ (see: **Pi-hole Web Admin UI** section). Set the two custom IPv4 addresses to the Cloudflare DNS addresses you recorded earlier \<OR\> use one of the preset DNS locations (I'd still recommend choosing Cloudflare's _1.1.1.1_, if nothing else...).

<br>

* **Note**: I could have mentioned firewall configurations earlier than now... Depending on your server/PC setup, you may not need to worry about this; chances are if you think you might, you probably don't. Run `netstat -tuln | grep <port-numbers>` to verify. If nothing is returned at your terminal, go ahead and run the commands below to update your firewall.
   * The basic command (for Linux users) is:

  ```bash
   sudo firewall-cmd --add-port=<port_num>/<protocol> --permanent

   ```
   _(where ```<port_num>``` is the port number, and ```<protocol>``` is the Transport-layer protocol: either ```tcp``` or ```udp```; both for port 53)_

   * ... followed by a:

   ```bash
   sudo systemctl reload firewalld
   ```
   (you're welcome... 😁).
