[![Travis Build](https://img.shields.io/travis/com/mageops/docker-raccoon?label=Docker+Image+Build)](https://travis-ci.com/mageops/docker-raccoon)

# MageOps Raccoon Docker Containers

Local development (and demo) containers
[running full *CentOS 7* system](https://github.com/mageops/docker-centos-systemd)
 provisioned with [MageOps Ansible Infrastructure](https://github.com/mageops/ansible-infrastructure) code.

⚡️ *Jump straight to the [Demo](#demo) section to see some action.*

## Containers

- [`mageops/centos-systemd`](https://github.com/mageops/docker-centos-systemd) - clean system with systemd init
- `mageops/raccoon-base-centos` - the fat version of the above container - with preinstalled (but not configured) package
- `mageops/raccoon-base-ansible` - the above with [MageOps Ansible Infrastructure](https://github.com/mageops/ansible-infrastructure) code installed and easily runnable
- `mageops/raccoon` - the above provisioned as a Magento development environment with no app installed
- `mageops/raccoon-demo` - an out-of-the-box, fully functional, production-configured [MageSuite](https://magesuite.io) demo shop provisioned unto `mageops/raccoon`

### Ansible

Ansible code is preinstalled inside the containers in `/opt/mageops/ansible`
and basic functionality is easily accesible using scripts prefixed with `mageops-`
which you can find in `/opt/mageops/bin` or use directly as they are symlinked
into `/usr/local/bin`.

### Development

_Read this section if you want a self-contained, isolated and easy to use [MageSuite](https://magesuite.io)
(or Magento) development environment._

This container has no code installed so it's wont do anything for you
unless you have some Magento code and set it up.

> 💡 The containers don't need the docker `privileged` mode, however, it may be good to use
> in some cases if you need to do some advanced debugging (like using `strace`).

More information coming soon...

### Demo

Start the docker container:

```
docker run \
    --interactive \
    --tty \
    --rm \
    --tmpfs /run:exec \
    --tmpfs /tmp:exec \
    --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
    --publish 80:8080 \
    --publish 443:443 \
        mageops/raccoon-demo
```

Once its fully started you can open [the shop](http://localhost/) in your browser.

In case you are attached with interactive tty (recommended!) you will know
when it's ready, otherwise observe the docker health status.

You can get to [the admin](http://localhost/admin/)
using `admin` as user and `racc00n` for password.

_PS Port `8080` is varnish._

> 💡Using `magesuite.me` host is also possible for HTTPs but you'd have
> to add the line `127.0.0.1 magesuite.me` to your `/etc/hosts` file.

> ⚠️ The whole system is in *production* mode which means the `demo` container
> is not suitable for development.