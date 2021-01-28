# docker-xcaddy

## Create docker image

    $ docker login registry.gitlab.com

    $ docker build -t registry.gitlab.com/cty3000/docker-xcaddy .

    $ docker run -dit --rm -p 80:8080 --name xcaddy registry.gitlab.com/cty3000/docker-xcaddy

    $ docker ps -a

    $ docker stop xcaddy

    $ docker push registry.gitlab.com/cty3000/docker-xcaddy
