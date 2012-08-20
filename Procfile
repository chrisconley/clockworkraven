web: bundle exec thin start -p $PORT -e $RACK_ENV
worker: QUEUE=* rake resque:work
