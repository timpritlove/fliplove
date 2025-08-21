OPENWEATHERMAP_API_KEY=`op item get k6jnh2x2bjy6mtxqgay6jrguae --reveal  --fields 'label=API Key'`
if [ $? -eq 0 ]; then
  export FLIPLOVE_OPENWEATHERMAP_API_KEY=$OPENWEATHERMAP_API_KEY
fi
TELEGRAM_BOT_SECRET=`op item get wo7rthz4u4jlyrshzz53yfhbse --reveal --fields 'label=Passwort'`
if [ $? -eq 0 ]; then
  export FLIPLOVE_TELEGRAM_BOT_SECRET=$TELEGRAM_BOT_SECRET
fi
#export FLIPLOVE_DRIVER=FLUEPDOT_WIFI
#export FLIPLOVE_DRIVER=FLUEPDOT_USB
export FLIPLOVE_DRIVER=DUMMY
#export FLIPLOVE_DRIVER=FLIPFLAPFLOP

#export FLIPLOVE_HOST=FLIPLOVE_02.local
#export FLIPLOVE_HOST=FLIPLOVE_05.local
export FLIPLOVE_HOST=flipdot.local
export FLIPLOVE_DEVICE=/dev/tty.usbserial-83420

#export FLIPLOVE_LATITUDE=52.5363101
#export FLIPLOVE_LONGITUDE=13.4273403
#export FLIPLOVE_APP=dashboard

#export FLIPLOVE_TIMEZONE="+01:00"
#export FLIPLOVE_MEGABITMETER_DEVICE=/dev/tty.usbserial-A700fn51
export FLIPLOVE_LANGUAGE=de

export FLIPLOVE_TIMETABLE_STOP=900110020
