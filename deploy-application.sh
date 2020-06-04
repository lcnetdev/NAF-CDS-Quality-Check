#!/bin/bash

##################################################################
# This protects against not being able to locate the `config` file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/gradlew-params

./gradlew --info mlDeploy -Pignore=LoadModulesCommand -PenvironmentName=$ENVIRO -PmlUsername=$MLADMIN -PmlPassword=$MLPASSWORD