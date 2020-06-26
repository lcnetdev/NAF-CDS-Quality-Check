#!/bin/bash

##################################################################
# This protects against not being able to locate the `config` file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/gradlew-params

if [ "$ACTION" == "reload" ];
then
    ./gradlew --info mlReloadModules -PenvironmentName=$ENVIRO -PmlUsername=$MLADMIN -PmlPassword=$MLPASSWORD
elif [ "$ACTION" == "watch" ];
then
    ./gradlew --info mlWatch -PenvironmentName=$ENVIRO -PmlUsername=$MLADMIN -PmlPassword=$MLPASSWORD
else
    ./gradlew --info mlLoadModules -PenvironmentName=$ENVIRO -PmlUsername=$MLADMIN -PmlPassword=$MLPASSWORD
fi

