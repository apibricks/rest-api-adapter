#!/bin/bash

# Absolute path to this script
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")

swaggerYamlPath=/api/swagger
swaggerControllerPath=/api/controllers
generatorPath=/generators

# Function to test if a given command exists
cmd_exists () {
 type "$1" &> /dev/null;
}


echo "### Removing old *.yaml files from directory $SCRIPTPATH$swaggerYamlPath"
cd $SCRIPTPATH$swaggerYamlPath
rm -f *.yaml

echo "### Removing old *.yaml files from directory $SCRIPTPATH$generatorPath"
cd $SCRIPTPATH$generatorPath
rm -f *.yaml

echo "### Removing old gen_ files from directory $SCRIPTPATH$swaggerControllerPath"
cd $SCRIPTPATH$swaggerControllerPath
rm -f gen_*.js

echo "### Removing old gen_ files from directory $SCRIPTPATH$generatorPath"
cd $SCRIPTPATH$generatorPath
rm -f gen_*.js

echo "### Generating Swagger file using proto3-file as input."
cd $SCRIPTPATH$generatorPath
node swagger_gen.js

echo "### Copying Swagger file to directory $SCRIPTPATH$swaggerYamlPath"
cd $SCRIPTPATH$generatorPath
cp ./swagger.yaml $SCRIPTPATH$swaggerYamlPath

echo "### Generating Swagger Controller Implementations using proto3-file as input."
cd $SCRIPTPATH$generatorPath
node swagger_controller_gen.js

echo "### Copying Swagger Controller Implementation files to directory $SCRIPTPATH$swaggerControllerPath"
cd $SCRIPTPATH$generatorPath
cp ./gen_*.js $SCRIPTPATH$swaggerControllerPath

echo "### Generating HTML representation of Swagger Specification from $swaggerYamlPath"
cd $SCRIPTPATH
if cmd_exists bootprint; then
  if cmd_exists html-inline; then
    bootprint swagger ./api/swagger/swagger.yaml html
    html-inline -i ./html/index.html -o ./html/inline-index.html
  else
    echo "ERROR: command html-inline could not be found"
    echo "Skipping Swagger to HTML process"
  fi
else
  echo "ERROR: command bootprint could not be found"
  echo "Skipping Swagger to HTML process"
fi

echo "### Waiting for ${ADAPTER_HOST}:${ADAPTER_PORT} to get ready..."
while ! nc -vz ${API_HOST} ${API_PORT}
do
  echo "### Retry..."
  sleep 3;
done

echo "### Starting Swagger Project."
cd $SCRIPTPATH
swagger project start
