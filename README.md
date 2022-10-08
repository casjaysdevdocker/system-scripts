## 👋 Welcome to system-scripts 🚀  

system-scripts README  
  
  
## Run container

```shell
dockermgr update system-scripts
```

### via command line

```shell
docker pull casjaysdevdocker/system-scripts:latest && \
docker run -d \
--restart always \
--name casjaysdevdocker-system-scripts \
--hostname casjaysdev-system-scripts \
-e TZ=${TIMEZONE:-America/New_York} \
-v $HOME/.local/share/srv/docker/system-scripts/files/data:/data:z \
-v $HOME/.local/share/srv/docker/system-scripts/files/config:/config:z \
-p 80:80 \
casjaysdevdocker/system-scripts:latest
```

### via docker-compose

```yaml
version: "2"
services:
  system-scripts:
    image: casjaysdevdocker/system-scripts
    container_name: system-scripts
    environment:
      - TZ=America/New_York
      - HOSTNAME=casjaysdev-system-scripts
    volumes:
      - $HOME/.local/share/srv/docker/system-scripts/files/data:/data:z
      - $HOME/.local/share/srv/docker/system-scripts/files/config:/config:z
    ports:
      - 80:80
    restart: always
```

## Authors  

🤖 casjay: [Github](https://github.com/casjay) [Docker](https://hub.docker.com/r/casjay) 🤖  
⛵ CasjaysDevDocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/r/casjaysdevdocker) ⛵  
