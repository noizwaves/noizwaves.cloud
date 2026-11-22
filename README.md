# noizwaves.cloud

A self hosted cloud

## Requirements

1.  Install Ansible locally via:
    1.  `mise install`
    1.  `ansible-galaxy install -r requirements.yml`

## Setup

1.  `ansible-playbook -i inventory.yaml playbook.yaml`
1.  SSH into nodes and manage individual applications directly

### Adding new machines

For each new machine:

1.  Install Ubuntu LTS
    1.  Username: `cloud`
    1.  Enable SSH server
    1.  Import SSH keys from GitHub
1.  Bootstrap as root using `bash <(curl https://raw.githubusercontent.com/noizwaves/noizwaves.cloud/main/ansible/bootstrap.sh)`
1.  Connect to Tailscale
1.  Run ansible playbook
1.  Populate `.envrc`
1.  Setup crontabs
1.  [Setup Samba](https://ubuntu.com/tutorials/install-and-configure-samba#1-overview)
    -  add shared directories
    -  set cloud Samba password
1.  Add to the inventory and ssh config

### Automation

1.  `$ crontab -e`
1.  Enable automated daily 1am hot backups with this cron config:
```
SHELL=/bin/bash
MAILTO=""
HOME=/home/cloud

0 1 * * * ./cloud-config/backups/hot/backup.sh >cloud-config/hot_backup.log 2>&1
```
1.  Enable DNS healthchecks with cron config:
```
*/2 * * * * host www.google.com 127.0.0.1 && <healthchecks.io health check>
```

## Applications

### Foundation

- [Authelia](./authelia/)
- [Traefik](./traefik/)
- [Adguard Home](./adguard/)
- [ntfy](./ntfy/)

### Stable

- [Homebox](./homebox/)
- [Bitwarden](./bitwarden/)
- [Speedtest](./speedtest/)
- [UpSnap](./upsnap/)
- [Resilio Sync](./resilio-sync/)
- [FreshRSS](./freshrss/)
- [Fotos Adam](./fotos/) and [Fotos Lauren](./fotos-lauren/)
- [Tandoor](./tandoor/)
- [Plex](./plex/)
- [FileBrowser Quantum](./filebrowser/)
- [Vikunja](./vikunja/)
- [Syncthing](./syncthing/)
- [Gitea](./gitea/)
- [Atuin](./atuin/)
- [Immich](./immich/)
- [Beszel](./beszel/)
- [Home Assistant](./homeassistant/)

### Incubating

- [BookOrbit](./bookorbit/)
- [Sure](./sure/)

### Inactive

Retired services are kept in [_inactive](./_inactive/).

## Maintenance

### Merging Renovate PRs

Run `./bin/merge-renovate-prs` with authenticated `gh` and `jq` installed. It lists
minor and patch PRs with clickable links and asks for confirmation; Enter accepts.
Use `--major`, `--minor`, and `--patch` to select exactly those types, for example
`./bin/merge-renovate-prs --patch` or
`./bin/merge-renovate-prs --major --minor --patch`.

PRs are squash-merged sequentially. Drafts and unrecognized update types are
skipped. Changed commits or unmet GitHub merge requirements cause a merge to fail.
Failures are reported without stopping other merges, and the script exits nonzero
if any fail. It works from any directory.

### Pulling updates

Run `./bin/pull-updates` on the server with your usual environment variables loaded
(for example, via direnv). It works from any directory.

The script requires a clean tracked working tree and runs `git pull --ff-only`.
For each top-level app with a running Compose container, it runs `docker compose up -d`
if any tracked file in that app's directory changed during the pull. Stopped apps,
projects outside this checkout, and `_inactive/` are skipped. Existing Compose project
names are preserved.

Updates run sequentially. Failures are summarized without stopping other updates,
and the script exits nonzero if any fail. Retry failed apps manually: rerunning the
script will not retry changes that were already pulled.

### Upgrading to newer images

1.  Update tags to desired newer value
1.  Recreate containers via `$ docker-compose up --force-recreate --build -d`

Postgres major version bumps need more than a tag change; see [Postgres major upgrades](./docs/postgres-major-upgrade.md).

### Upgrading PostgreSQL

After pulling a major image update, run `./bin/upgrade-postgres <service>` before
`docker compose up`, while the previous database container is still running.
Load the application's usual environment variables first. Requires Docker Compose,
`jq`, and `realpath`.

The script stops the project's other containers, dumps the application database,
stops PostgreSQL, renames its data directory to
`<directory>-previous-pg<major>-<timestamp>-<pid>`, creates an empty directory, and
starts and restores only the new database. Run `docker compose up -d` from the
application directory afterward. Dumps are deleted on exit; previous directories
remain for manual cleanup or rollback.

Unchanged major versions are skipped. Downgrades, changed data paths, extra user
roles, and extra databases are refused. A failed dump leaves the old database
running; a failed restore stops the new database. See the runbook for rollback.

## Disaster Recovery and Backups

See [backups](./backups/).

## Useful diagnostic tools

### iotop
1.  `sudo apt install iotop`
1.  `iotop`

### iozone
1.  `sudo apt install iozone3`
1.  `sudo iozone -e -I -a -s 100M -r 4k -r 16k -r 512k -r 1024k -r 16384k -i 0 -i 1 -i 2`

### hdparm
1.  `sudo apt install hdparm`
1.  `sudo hdparm -t /dev/nvme0n1`

### inxi
1.  `sudo apt install inxi`
1.  `inxi -Dxxx`
