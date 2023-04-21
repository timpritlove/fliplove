# Flipdot

This is experimental code to build a driver environment for dealing with a fluepdot enabled
flipdot display. It's all work in progress and primarily a system for learning elixir and OTP.

https://github.com/Fluepke/Fluepdot

It comes with a basic bitmap library for monochrome pixels with a limited set of 
basic graphical operations (setting pixels, flipping, inverting) and some fancy filters 
and generators. It also contains a super simple Telegram bot plugin.

There is a LiveView based web server that shows the current display state and allows
for a set of basic operations (setting images, applying filters, painting pixels and lines, filling).

When a fluepdot-based display is connected via either UDP or USB the system
can be configured to sync its current virtuel display state to the real display. Set the 