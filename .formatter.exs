[
  import_deps: [:phoenix],
  locals_without_parens: [defbitmap: 1],
  line_length: 120,
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: ["*.{heex,ex,exs}", "{config,lib,test}/**/*.{heex,ex,exs}"]
]
