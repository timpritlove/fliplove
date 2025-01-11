# Fliplove

This is experimental code to build a driver environment for dealing with low resolution
flipdot displays.

Fliplove is completely written in Elixir and is considered an experimental project exploring
the capabilities of the language and the OTP framework.

It comes with a basic bitmap library for monochrome pixels with a limited set of 
basic graphical operations (setting pixels, flipping, inverting) and some fancy filters 
and generators. It also features some other fun integration like a super simple Telegram bot plugin,
showing the number of pixels used on the Megabitmeter device among other things.

The system can deal with BDF pixel fonts (from the old age of X Windows). The parser should be
able to handle most of the fonts out there. There some builtin fonts that are always available.

There is a LiveView based web server that shows the current display state and allows
for a set of basic operations (setting images, applying filters, painting pixels and lines, filling). 
The virtual display mirrors what is being seen on the real display and can simulate the display speed
by enabling a "delay mode" that tries to match the speed of the real display.

The system has a basic concept of "apps" that run in the background and that define what 
is being seen on the display. This could be expanded to various uses. There is a basic dashboard
shwoing a clock and a weather forecast for the next 48 hours. There is a Fluepdot Server app
that simulates the Wifi API of a Fluepdot display and can be used to test the system.

You can start and stop the apps on the web page. 


Supported displays:

- Fluepdot (via Wifi or USB)

https://github.com/Fluepke/Fluepdot

- Flipflapflop (via USB)

https://github.com/tbs1-bo/flipflapflop

- Dummy

This is a dummy display that can be used for testing. It's a simple terminal that shows the current state of the display.

## Weather Service Configuration

The application supports multiple weather service providers. Currently implemented are:

### OpenMeteo (Default)
- Free service, no API key required
- Provides up to 16 days of hourly forecast data
- Configure using:
  ```elixir
  config :fliplove, :weather,
    service: :open_meteo
  ```

### OpenWeather
- Requires an API key
- Provides up to 48 hours of forecast data
- Configure using:
  ```elixir
  config :fliplove, :weather,
    service: :open_weather
  ```
- Required environment variables:
  - `FLIPLOVE_OPENWEATHERMAP_API_KEY`: Your OpenWeather API key
  - Or place your API key in `data/keys/openweathermap.txt`

### Location Configuration
Both services require location information which can be provided through:
- Environment variables:
  - `FLIPLOVE_LATITUDE`: Your location's latitude
  - `FLIPLOVE_LONGITUDE`: Your location's longitude
- If not provided, the application will attempt to determine location using IP geolocation