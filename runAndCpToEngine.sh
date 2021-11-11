#!/bin/bash
# variables
SESSION_NAME='ipcontroller'
FILE=/home/emadi/.ipython/profile_default/security/ipcontroller-engine.json

# terminate all screen
screen -ls "$SESSION_NAME" | (
  IFS=$(printf '\t');
  sed "s/^$IFS//" | while read -r name stuff; do screen -S "$name" -X quit ; done)

# load ip controller
rm /home/emadi/.ipython/profile_default/security/ipcontroller-*
screen -S ipcontroller -d -m ipcontroller --ip=* --ssh=217.219.162.134
while [ ! -f "$FILE" ]; do sleep 1 ; done # wait to file generate

# local engines
## terminate ipengies
screen -ls "ipengine" | (
  IFS=$(printf '\t');
  sed "s/^$IFS//" | while read -r name stuff; do screen -S "$name" -X quit ; done)
## run
screen -S ipengine$i -d -m mpiexec -n 10 ipengine
#for i in {1..22}
#do
#screen -S ipengine$i -d -m ipengine 
#done

# Engine 87.107.99.27
ssh live@87.107.99.27 "/home/emadi/ilia/terminateEngine.sh"
#scp $FILE live@87.107.99.27:/home/emadi/ilia/

#for i in {1..30}
#do
#ssh live@87.107.99.27 "screen -S ipengine$i -d -m /home/emadi/anaconda3/bin/ipengine --file=/home/emadi/ilia/ipcontroller-engine.json"
#done

# Engine *
#

sleep 5
#python3 /home/jupyter/MultiCluster/getIpEnginesIds.py
exit 0