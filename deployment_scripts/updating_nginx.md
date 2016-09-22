### Deploying new container

After building and running a new container using `shiny_dockder`: 

- get container IP address with `docker inspect --format '{{ .NetworkSettings.IPAddress }}' <container_name>`
- update the nginx config file at `~/conf.d/default.conf` with the name and IP address (always at port 3838)
- restart docker with `docker kill -s HUP nginx` and `docker restart nginx`

### Updating shiny website

- go to app on firefox to test link
- get screenshot or GIF
- make new entry on website

### Starting NGINX container

In case the nginx container goes down, start it with:

`docker run --name nginx -v /home/ubuntu/conf.d:/etc/nginx/conf.d:ro -p 80:80 -d nginx`
