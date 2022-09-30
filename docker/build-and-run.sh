#/usr/bin/bash

# Image name prefix
NAME_PREFIX=timodonnell/openfold-dev:

for target in base dev pycharm
do
    FULL_NAME="${NAME}${target}"
    docker build -t $FULL_NAME --target $target .
done

nvidia-docker run -p 5993:5993 -v ~/.gitconfig:/etc/gitconfig -v ~/.ssh:/root/.ssh -it $FULL_NAME "$@"

