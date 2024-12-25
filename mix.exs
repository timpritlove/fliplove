defmodule Flipdot.MixProject do
  use Mix.Project

  def project do
    [
      app: :flipdot,
      name: "The Flipdot Controller Project",
      docs: [
        authors: ["Tim Pritlove"],
        logo: "data/flipdot-logo-64.jpg"
      ],
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      escript: [
        main_module: Flipdot.CLI.SymbolImporter,
        name: "symbol_importer",
        app: nil,
        included_applications: [:logger, :ex_png],
        path: "_build/tools/symbol_importer"
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Flipdot.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :tz, :tzdata]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "experimental"]
  defp elixirc_paths(_), do: ["lib", "experimental"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.0"},
      {:phoenix_html, ">= 3.3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:heroicons, "~> 0.5"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, ">= 0.1.8", runtime: Mix.env() == :dev},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:nimble_parsec, ">= 1.2.3"},
      {:nimble_options, "~> 1.0", override: true},
      {:bandit, ">= 0.6.9"},
      {:telegram, github: "visciang/telegram", tag: "0.22.4"},
      {:httpoison, "~> 2.0"},
      {:pngex, "~> 0.1.0"},
      {:ex_png, "~> 1.0.0"},
      {:tz, ">= 0.24.0"},
      {:gen_icmp, git: "https://github.com/hauleth/gen_icmp.git"},
      # {:pixel_generator, git: "https://github.com/Reimerei/pixel_generator.git"},
      {:ex_fontawesome, ">= 0.7.2"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      #      {:circuits_uart, "~> 1.5"},
      {:easing, "~> 0.3.1"},
      {:logger_file_backend, "~> 0.0.13"},
      {:circuits_uart, "~> 1.5"},
      {:tzdata, "~> 1.1"},
      {:mdns_lite, "~> 0.8.11"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
