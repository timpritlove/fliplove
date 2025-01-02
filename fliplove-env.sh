OPENWEATHERMAP_API_KEY=`security find-generic-password -a tim@pritlove.org -s "OpenWeatherMap API Key" -w` 2>/dev/null
if [ -n "$OPENWEATHERMAP_API_KEY" ]; then
  export FLIPLOVE_OPENWEATHERMAP_API_KEY=$OPENWEATHERMAP_API_KEY
fi
TELEGRAM_BOT_SECRET=`security find-generic-password -a FLIPLOVE_update_bot -s "Telegram" -w` 2>/dev/null
if [ -n "$TELEGRAM_BOT_SECRET" ]; then
  export FLIPLOVE_TELEGRAM_BOT_SECRET=$TELEGRAM_BOT_SECRET
fi
export FLIPLOVE_DRIVER=FLUEPDOT_WIFI
#export FLIPLOVE_DRIVER=FLUEPDOT_USB
#export FLIPLOVE_DRIVER=DUMMY
#export FLIPLOVE_DRIVER=FLIPFLAPFLOP

#export FLIPLOVE_HOST=FLIPLOVE_02.local
#export FLIPLOVE_HOST=FLIPLOVE_05.local
export FLIPLOVE_HOST=flipdot.local
export FLIPLOVE_DEVICE=/dev/tty.usbserial-130
#export FLIPLOVE_LATITUDE=52.5363101
#export FLIPLOVE_LONGITUDE=13.4273403
#export FLIPLOVE_APP=dashboard

#export FLIPLOVE_MEGABITMETER_DEVICE=/dev/tty.usbserial-A700fn51
