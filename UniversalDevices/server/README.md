# `server`

```bash
podman run --rm -it -v $(pwd)/config.toml:/app/config.toml:ro,Z -w /app --network=host universal-devices-proxy:latest
```
