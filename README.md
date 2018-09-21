# Shiny Server Pro in Docker image

Run container:
```
docker pull kfoltynski/shiny-server-pro:0.1.0

docker run -d -p 3838:3838 -p 4151:4151 kfoltynski/shiny-server-pro:0.1.0

```
Shiny Server should be available on `localhost:3838`
Dashboard should be available on `localhost:4151`