# docker-xcaddy

## Create docker image

    $ docker build -t ghcr.io/cty3000/docker-xcaddy .

    $ docker run -dit --rm -p 80:8080 --name xcaddy ghcr.io/cty3000/docker-xcaddy

    $ docker ps -a

    $ docker stop xcaddy

    $ docker push ghcr.io/cty3000/docker-xcaddy
