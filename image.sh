#!/bin/bash
 
export IMAGE_NAME_RSTUDIO=shiny-server-pro:R3.4.3
export RSTUDIO=shiny-pro
export CORE_DIR="/mnt/vol"
# save annos in user's home dir
export HOME_DIR="$(eval echo '~')/.facileexplorer"

declare -a NAMES=("$RSTUDIO-1" "$RSTUDIO-2" "$RSTUDIO-3")
declare -a SHINY_PORTS=("3840" "3841" "3842")

set -e

remove_exited() {
  
  [ ! -z  "$(docker ps -a -q -f name=$RSTUDIO)" ] && docker rm -f $(docker ps -a -q -f name=$RSTUDIO)
  
  if [ ! -z "$(docker ps -q -f status=exited)" ]; then
    docker rm $(docker ps -q -f status=exited) && \
    echo "Removing containers on status=exited..."
  else
    echo "Nothing to remove"
  fi
}

if [ "$1" == "rstudio" ]; then

  remove_exited
  
  docker run --name $RSTUDIO -d \
             -p 3839:3838 \
             -p 4151:4151 \
             -v $(pwd)/shinylog/:/var/log/shiny-server/ \
             -v `pwd`:$CORE_DIR $IMAGE_NAME_RSTUDIO

elif [ "$1" == "multirun" ]; then
  
  for i in ${!NAMES[@]}
  do
     echo "Running container ${NAMES[$i]} on port ${SHINY_PORTS[$i]}"
     
     docker run --name ${NAMES[$i]} -d \
           -p ${SHINY_PORTS[$i]}:3838 \
           -v $(pwd)/shinylog/:/var/log/shiny-server/ \
           -v `pwd`:$CORE_DIR $IMAGE_NAME_RSTUDIO
  done
  
elif [ "$1" == "multistop" ]; then

  for i in ${!NAMES[@]}
  do
     echo "Stopping container ${NAMES[$i]}"
     docker stop ${NAMES[$i]}
  done
  
           
elif [ "$1" == "stop" ]; then

  docker stop $RSTUDIO

elif [ "$1" == "build" ]; then

  SHINY_PRO_KEY="$2"
  docker build --build-arg SHINY_PRO_KEY=$SHINY_PRO_KEY -t shiny-server-pro:R3.4.3 -f Dockerfile-R3.4.3 .

fi