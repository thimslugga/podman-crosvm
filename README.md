# podman-crosvm

## The Chrome OS Virtual Machine Monitor

[`crosvm`](https://chromium.googlesource.com/chromiumos/platform/crosvm/)

is a lightweight VMM written in Rust. It runs on top of KVM and
optionally runs the device models in separate processes isolated with
seccomp profiles.


## Build/Install

The `Makefile` and `Dockerfile` compile `crosvm` and a suitable
version of `libminijail`. To build:

```sh
make
```

You should end up with a `crosvm` and `libminijail.so` binaries as
well as the seccomp profiles in `./build`. Copy `libminijail.so` to
`/usr/lib` or wherever `ldd` picks it up. You may also need `libcap`
(on Ubuntu or Debian `apt-get install -y libcap-dev`).

You may also have to create an empty directory `/var/empty`.


## Use with LinuxKit images

You can build a LinuxKit image suitable for `crosvm` with the
`kernel+squashfs` build format. For example, using `minimal.yml` from
the `./examples` directory, run (but also see the known issues):

```sh
linuxkit build -format kernel+squashfs -decompress-kernel minimal.yml
```

The `-vmlinux` switch is needed since `crosvm` does not grok
compressed linux kernel images.

Then you can run `crosvm`:
```sh
crosvm run --disable-sandbox \
    --root ./minimal-squashfs.img \
    --mem 2048 \
    --socket ./linuxkit-socket \
    minimal-kernel
```
