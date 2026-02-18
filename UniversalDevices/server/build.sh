cargo b -r --target x86_64-unknown-linux-musl
podman build -t universal-devices-proxy:latest .
podman save -o target/universal-devices-proxy.tar universal-devices-proxy:latest