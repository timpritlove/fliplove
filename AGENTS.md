This is a web application written using the Phoenix web framework for controlling flipdot displays.

## Project guidelines

- Use `mix precommit` alias when you are done with all changes and fix any pending issues
- Use the already included and available `:req` (`Req`) library for HTTP requests, **avoid** `:httpoison`, `:tesla`, and `:httpc`. Req is included by default and is the preferred HTTP client for Phoenix apps

## Fliplove-specific guidelines

### Hardware and Display Control
- **Flipdot displays** are electromechanical pixel displays that can show monochrome bitmaps
- Supported hardware: Fluepdot (WiFi/USB), Flipflapflop (USB), and Dummy (terminal simulator)
- All display operations use the `Fliplove.Driver` module for hardware abstraction
- Use `Fliplove.Display.update/1` to send bitmaps to connected displays
- **Always** test with the Dummy driver first before connecting real hardware

### Bitmap and Graphics Operations
- Use `Fliplove.Bitmap` for all monochrome bitmap operations (create, manipulate, transform)
- Bitmaps are represented as structs with `:width`, `:height`, and `:data` fields
- **Always** use `Fliplove.Bitmap.new/2` to create bitmaps with proper dimensions
- Pixel coordinates are `{x, y}` tuples where `{0, 0}` is top-left corner
- Use `Fliplove.Bitmap.put_pixel/3`, `draw_line/5`, `draw_rectangle/6` for basic graphics
- Apply filters and transformations using `Fliplove.Bitmap.Filter` and `Fliplove.Bitmap.Transition`

### Font System and Text Rendering
- Use BDF (Bitmap Distribution Format) fonts via `Fliplove.Font` modules
- Built-in fonts: `Fliplove.Font.Fonts.Flipdot`, `Fliplove.Font.Fonts.SpaceInvaders`, etc.
- **Always** use `Fliplove.Font.Renderer.place_text/3` for text rendering with proper positioning
- Load custom fonts with `Fliplove.Font.Parser.parse/1` from BDF files in `data/fonts/`
- Handle kerning and text layout using `Fliplove.Font.Kerning` for better text appearance

### Application Framework
- Background apps control display content and inherit from `Fliplove.Apps.Base` behavior
- Available apps: Dashboard (clock + weather), DateTime, Slideshow, Symbols, Maze Solver, etc.
- **Always** implement `start_link/1`, `stop/1`, and the required callbacks when creating new apps
- Use `Fliplove.Apps.start_app/1` and `Fliplove.Apps.stop_app/1` for app lifecycle management
- Apps run as GenServers and should update display content via `Fliplove.Display.update/1`

### Weather Integration
- Supports OpenMeteo (free, default) and OpenWeather (API key required) services
- Configure via `:fliplove, :weather` settings in `config/config.exs`
- Location can be set via environment variables or IP geolocation
- Weather data includes temperature, conditions, and 48-hour forecasts

### File Organization
- Fonts, images, and display frames go in `data/` directory
- Display drivers in `lib/fliplove/driver/`
- Apps in `lib/fliplove/apps/`
- Web interface in `lib/fliplove_web/`
- **Never** modify generated files in `_build/` or `deps/`

### Development and Testing
- Use `mix test` for comprehensive test suite covering bitmap operations and display drivers
- Test display operations with Dummy driver before using real hardware
- Use IEx for interactive development: `iex -S mix phx.server`
- Hot code reloading available in development mode

<!-- usage-rules-start -->
<!-- phoenix:elixir-start -->
## Elixir guidelines

- Elixir lists **do not support index based access via the access syntax**

  **Never do this (invalid)**:

      i = 0
      mylist = ["blue", "green"]
      mylist[i]

  Instead, **always** use `Enum.at`, pattern matching, or `List` for index based list access, ie:

      i = 0
      mylist = ["blue", "green"]
      Enum.at(mylist, i)

- Elixir variables are immutable, but can be rebound, so for block expressions like `if`, `case`, `cond`, etc
  you *must* bind the result of the expression to a variable if you want to use it and you CANNOT rebind the result inside the expression, ie:

      # INVALID: we are rebinding inside the `if` and the result never gets assigned
      if connected?(socket) do
        socket = assign(socket, :val, val)
      end

      # VALID: we rebind the result of the `if` to a new variable
      socket =
        if connected?(socket) do
          assign(socket, :val, val)
        end

- **Never** nest multiple modules in the same file as it can cause cyclic dependencies and compilation errors
- **Never** use map access syntax (`changeset[:field]`) on structs as they do not implement the Access behaviour by default. For regular structs, you **must** access the fields directly, such as `my_struct.field` or use higher level APIs that are available on the struct if they exist, `Ecto.Changeset.get_field/2` for changesets
- Elixir's standard library has everything necessary for date and time manipulation. Familiarize yourself with the common `Time`, `Date`, `DateTime`, and `Calendar` interfaces by accessing their documentation as necessary. **Never** install additional dependencies unless asked or for date/time parsing (which you can use the `date_time_parser` package)
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Predicate function names should not start with `is_` and should end in a question mark. Names like `is_thing` should be reserved for guards
- Elixir's builtin OTP primitives like `DynamicSupervisor` and `Registry`, require names in the child spec, such as `{DynamicSupervisor, name: MyApp.MyDynamicSup}`, then you can use `DynamicSupervisor.start_child(MyApp.MyDynamicSup, child_spec)`
- Use `Task.async_stream(collection, callback, options)` for concurrent enumeration with back-pressure. The majority of times you will want to pass `timeout: :infinity` as option

## Mix guidelines

- Read the docs and options before using tasks (by using `mix help task_name`)
- To debug test failures, run tests in a specific file with `mix test test/my_test.exs` or run all previously failed tests with `mix test --failed`
- `mix deps.clean --all` is **almost never needed**. **Avoid** using it unless you have good reason
<!-- phoenix:elixir-end -->
<!-- phoenix:phoenix-start -->
## Phoenix guidelines

- Remember Phoenix router `scope` blocks include an optional alias which is prefixed for all routes within the scope. **Always** be mindful of this when creating routes within a scope to avoid duplicate module prefixes.

- You **never** need to create your own `alias` for route definitions! The `scope` provides the alias, ie:

      scope "/admin", AppWeb.Admin do
        pipe_through :browser

        live "/users", UserLive, :index
      end

  the UserLive route would point to the `AppWeb.Admin.UserLive` module

- `Phoenix.View` no longer is needed or included with Phoenix, don't use it
<!-- phoenix:phoenix-end -->
<!-- phoenix:ecto-start -->
## Ecto Guidelines

- **Always** preload Ecto associations in queries when they'll be accessed in templates, ie a message that needs to reference the `message.user.email`
- Remember `import Ecto.Query` and other supporting modules when you write `seeds.exs`
- `Ecto.Schema` fields always use the `:string` type, even for `:text`, columns, ie: `field :name, :string`
- `Ecto.Changeset.validate_number/2` **DOES NOT SUPPORT the `:allow_nil` option**. By default, Ecto validations only run if a change for the given field exists and the change value is not nil, so such as option is never needed
- You **must** use `Ecto.Changeset.get_field(changeset, :field)` to access changeset fields
- Fields which are set programatically, such as `user_id`, must not be listed in `cast` calls or similar for security purposes. Instead they must be explicitly set when creating the struct
<!-- phoenix:ecto-end -->
<!-- usage-rules-end -->
