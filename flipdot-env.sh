OPENWEATHERMAP_API_KEY=`security find-generic-password -a tim@pritlove.org -s "OpenWeatherMap API Key" -w`
if [ -n "$OPENWEATHERMAP_API_KEY" ]; then
  export FLIPDOT_OPENWEATHERMAP_API_KEY=$OPENWEATHERMAP_API_KEY
fi
TELEGRAM_BOT_SECRET=`security find-generic-password -a flipdot_update_bot -s "Telegram" -w`
if [ -n "$TELEGRAM_BOT_SECRET" ]; then
  export FLIPDOT_TELEGRAM_BOT_SECRET=$TELEGRAM_BOT_SECRET
fi
#export FLIPDOT_MODE=NETWORK
#export FLIPDOT_MODE=USB
export FLIPDOT_MODE=DUMMY
#export FLIPDOT_HOST=flipdot_02.local
export FLIPDOT_HOST=flipdot_05.local
#export FLIPDOT_HOST=flipdot.local
export FLIPDOT_DEVICE=/dev/cu.usbserial-83420
export PHX_SERVER=true
#export FLIPDOT_LATITUDE=52.5363101
#export FLIPDOT_LONGITUDE=13.4273403
export FLIPDOT_APP=dashboard
