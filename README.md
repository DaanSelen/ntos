[![Docker Build and Push](https://github.com/DaanSelen/ntos/actions/workflows/docker.yml/badge.svg)](https://github.com/DaanSelen/ntos/actions/workflows/docker.yml)
[![CodeQL Advanced](https://github.com/DaanSelen/ntos/actions/workflows/codeql.yml/badge.svg)](https://github.com/DaanSelen/ntos/actions/workflows/codeql.yml)

> [!NOTE]
> If you experience issues or have suggestions, submit an issue: https://github.com/DaanSelen/ntos/issues — I'll respond ASAP!

# NTOS (Nerthus Thin Operating System)

**NTOS** is a lightweight, Debian-based ThinClient OS built as a free, minimal, and secure alternative to complex enterprise solutions.

## 🌟 About the Project

Hi there! Thanks for your interest in NTOS. This project began from a need for a simpler, more open, and cost-effective ThinClient solution in real-world IT environments.

As a student and young professional, I wanted to create something **production-ready**, **easily manageable**, and built on **open standards**. The result: NTOS.

* **Nerthus** – the domain: [nerthus.nl](https://nerthus.nl)
* **Thin** – for ThinClients
* **OS** – Operating System

---

## ✅ Why NTOS?

* **Debian-based** for stability and long-term support
* **Lightweight**: Runs on just **2GB RAM / 4GB storage**
* **XFCE4 Desktop**: Fast, clean, and resource-friendly
* **Credcon.sh**: Connects to remote desktops with a simple user prompt
* **Remote management** ready using tools like [MeshCentral](https://github.com/Ylianst/MeshCentral) with my [Meshbook](https://github.com/DaanSelen/meshbook) or other tools.

## 🔧 Getting Started

**Requirements:**

* A ThinClient or PC with internet and basic specs
* Debian installer (via [Rufus](https://rufus.ie/) or [Etcher](https://www.balena.io/etcher))
* Optional but recommended: a remote management agent installation in `setup-root.sh` (lines 6-8) in `./ntos/assets/tmp`

**Dependencies:**

* [FreeRDP](https://github.com/FreeRDP/FreeRDP)
* [yad](https://github.com/v1cont/yad)

## ⚙️ Deployment & Use

NTOS is built for **easy deployment** at scale.
I’ve used it in production across multiple machines, with minimal training required—even by non-IT users.

## 💡 Customization

NTOS is flexible by design. You can:

* Replace RDP with other protocols like VNC or Citrix, depending on Linux clients.
* Create kiosk-style launchers
* Automate deployment via preseeded ISOs or centralized scripts

Examples [Citrix Workspace](https://www.citrix.com/downloads/workspace-app/linux/) and [TigerVNC](https://github.com/TigerVNC/tigervnc)/[RealVNC](https://www.realvnc.com/en)

## 🖥️ Installation Guide

### 1. (Bare-Metal/VM) Set Up NTOS Server

Run the setup script:
```bash
bash install.sh
```

Verify the server:

```bash
curl http://localhost/configs/default/preseed.cfg
```

This should retrieve the Debian default preseed config.
Ensure the structure matches your network and use case.

### 2. Docker/Kubernetes

```bash
docker compose -f ./docker/compose.yaml up -d
```

This should start the container following the `./docker/compose.yaml` specifications. Look at those to be safe.

---
### 2. Install NTOS Client

1. Boot a client using a Debian ISO.
2. Choose “Graphical Automated Install” from advanced options.
3. When prompted, provide the NTOS-Server address and path to the config (e.g., `https://<your-NTOS-server-address>/configs/minimal/preseed.cfg`).
4. Proceed with partitioning:

   * **4GB storage**: Manual partitioning required
   * **8GB+ storage**: Use guided install
5. After installation completes (XFCE desktop should appear), run this inside the terminal as the user:

```bash
bash <(curl <your-NTOS-server-address>/configs/<your-config>/finish.sh)
```

This process on older hardware can take up to like 40 minutes. Because its just 2 action 'sessions' and lots of stuff in between.

---

## 🎨 Optional: Set Custom Boot Animation

For a more polished boot experience, use Plymouth themes:

* Choose a theme: [adi1090x/plymouth-themes](https://github.com/adi1090x/plymouth-themes)
* Follow guides:

  * [Debian Plymouth Wiki](https://wiki.debian.org/plymouth)
  * [Third-party Plymouth setup](https://donjajo.com/plymouth-installing-configuring-boot-screen-debian/)
  * [Arch Wiki (for reference)](https://wiki.archlinux.org/title/Plymouth)

---

## 📬 Feedback & Contribution

Feel free to contribute via pull requests or by opening an issue. You can also reach me by email (see GitHub profile).

---

## 📹 Video Guide

Watch the full walkthrough: [YouTube Link](https://www.youtube.com/watch?v=IZEBjlq8x00)

## 🛠️ How to Debug

### 🔌 RDP-Related Issues

If you're experiencing problems when connecting to the RDP session, follow these steps to debug effectively:

#### ✅ Ensure the DISPLAY Variable Is Set

Make sure the correct `DISPLAY` environment variable is set. Typically, this should be:

```bash
export DISPLAY=:0
```

You can set this via the **Terminal tab** (or in a management application such as: **MeshCentral**). As of the latest `finish.sh` scripts, this is also automatically appended to the user's `~/.bashrc`, so future sessions will apply it automatically.

> Setting this ensures that all graphical applications appear on the physical monitor, not just in the background or headlessly.

#### 🧪 Debugging `credcon.sh` with Output Logs

To run `credcon.sh` with output directly to the terminal (while GUI dialogs still appear on the desktop), use:

```bash
bash /opt/ntos/credcon.sh
```
Run the above as the user, something which can be done with `su user` (as root).

This will output real-time logs, which are useful for diagnosing connection problems. For example:

```
user@NTOS:/opt/ntos# bash credcon.sh
Starting loading bar
# 1%
# 2%
# 3%
[16:39:02:892] [8315:8327] [ERROR][com.freerdp.core] - freerdp_tcp_connect:freerdp_set_last_error_ex ERRCONNECT_DNS_NAME_NOT_FOUND [0x00020005]
# 4%
[16:39:02:946] [8315:8327] [ERROR][com.freerdp.core] - rdg_establish_data_connection:freerdp_set_last_error_ex ERRCONNECT_ACCESS_DENIED [0x00020016]
...
# 10%
xfreerdp terminated early (less than '30' seconds).
# 23%
```

#### 🧩 Common Errors Explained

* `ERRCONNECT_DNS_NAME_NOT_FOUND`: The hostname cannot be resolved. Check your RDP server address.
* `ERRCONNECT_ACCESS_DENIED`: Access was denied. Verify your credentials and user permissions.

---

### 🖼️ Desktop Environment (XFCE4) Issues

Sometimes, when connecting an additional monitor **after** installation, the desktop background may not sync correctly across displays.

To fix this, run the background sync script:

```bash
su user -c "bash /opt/ntos/background-sync.sh"
```

This command syncs the background image located at:

```
/opt/ntos/desktop.png
```

...across all currently connected monitors.
Since recent versions of NTOS, this should be fixed by replacing the default image.

---

## 🌐 NTOS Web Server File Structure

This outlines how key files are mapped when `copy_ntos_files()` places NTOS content into a web-accessible directory (e.g., `/var/www/html/ntos` or similar).

---

### 📁 `/assets/` – User Interface & Scripts

| Path                              | Description                                                                                        |
| --------------------------------- | -------------------------------------------------------------------------------------------------- |
| `/assets/desktop.png`             | Default background image applied to the XFCE4 desktop. Replace carefully (exact name + extension). |
| `/assets/gtk.css`                 | UI stylesheet to modernize appearance of GTK elements.                                             |
| `/assets/panel-profile.tar.bz2`   | XFCE4 panel profile archive; sets panel layout and shortcuts.                                      |
| `/assets/bin/background-sync.sh`  | Syncs background across multiple monitors (fixes multi-display misalignments).                     |
| `/assets/bin/blocked-dialogue.sh` | Script to show a "blocked" message when restricted apps are launched.                              |
| `/assets/bin/code-refresh.sh`     | Script to refresh config or system code from source.                                               |
| `/assets/bin/install-firmware.sh` | Script to assist with firmware package installation.                                               |

---

### 🔐 `/credcon/` – Credential Manager

| Path                  | Description                                                                                        |
| --------------------- | -------------------------------------------------------------------------------------------------- |
| `/credcon/credcon.sh` | Bash script prompting the user for RDP credentials, with basic validation and feedback mechanisms. |

---

### ⚙️ `/configs/` – Deployment Presets

| Path                           | Description                                                                                          |
| ------------------------------ | ---------------------------------------------------------------------------------------------------- |
| `/configs/minimal/preseed.cfg` | Debian preseed file for lightweight installs (targeting \~4GB storage).                              |
| `/configs/default/preseed.cfg` | Default preseed configuration (more general use).                                                    |
| `/configs/minimal/finish.sh`   | Post-install script for minimal installs; includes tweaks for low-storage environments.              |
| `/configs/default/finish.sh`   | Default finish script applied after installation. Insert remote management setup here (lines 84–87). |

---

### 🖥 `/rdp/` – Remote Desktop Configs

| Path         | Description                                                                                                                    |
| ------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| `/rdp/*.rdp` | Pre-made `.rdp` files for automatic connections. You must populate this folder manually with your environment’s RDP templates. |

---

### 🚫 `/assets/mime-blocks/` – Application Restrictions

| Path                                    | Description                                                                                                                  |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `/assets/mime-blocks/blocked-*.desktop` | XFCE `.desktop` entries that redirect to a block notice instead of launching restricted apps (e.g., Terminal, File Manager). |
| `/assets/mime-blocks/helpers.rc`        | Supporting config for the blocked app launchers.                                                                             |

---

### 🧪 `/vers-diff/` – Version-Specific Updates

| Path                      | Description                                                                                        |
| ------------------------- | -------------------------------------------------------------------------------------------------- |
| `/vers-diff/1.1-1.1.1.sh` | Script to update from version 1.1 to 1.1.1. Useful for applying incremental updates in production. |

---

### 📄 Miscellaneous

| Path       | Description                                                                  |
| ---------- | ---------------------------------------------------------------------------- |
| `/VERSION` | Defines the current NTOS version. Referenced during updates and deployments. |

---

## Images:
<img src="./assets/images/preseed.jpeg" alt="Preseed-screen" width="600"/><br>
<img src="./assets/images/partitioner.jpeg" alt="Partitioner screen" width="600"/><br>
<img src="./assets/images/firstboot.jpeg" alt="First-boot desktop" width="600"/><br>
<img src="./assets/images/finish_sh.jpeg" alt="Executing finish.sh" width="600"/><br>

# Epilogue
I am happy I am finally able to present something I am actually very fond of, this project.
I've tried to make this environment as fool-proof as possible so that non-technical people can work with this. I always appreciate feedback.
Thanks
