This is a Component meant to be used in the context of SURF Research Cloud (SRC), i.e. as one building blocks of a Catalog Item. Specifically, it is used in conjunction with a Docker environment component, that takes our "Docker compose" definition in 'docker-compose.yml' as a parameter.

The file 'init.sh' will be executed before the Docker environment gets built. It processes parameters entered through the SRC portal, and makes them available to a Docker container.

The other files are included for your convenience as they can be used to run this Docker configuration locally. Refer to the comments in the various files for more information.