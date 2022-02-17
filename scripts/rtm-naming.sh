#!/bin/sh

if [ -e $LOGDIR ]; then
  rm -rf $LOGDIR
fi

mkdir $LOGDIR

omniNames -start $PORT -logdir $LOGDIR &
sleep 1