# EctoCrux

Wip. Code works like a charm, unit test will be extracted soon.

## Guide usage

#### configuration:

```
config :ecto_crux, repo: MyApp.Repo
```

#### usage example:
For module schema "MyApp.Schema.Film, create a "MyApp.Schema.Films" module with:

```
defmodule MyApp.Schema.Films do
  use EctoCrux, module: MyApp.Schema.Film
end
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `crux` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:crux, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/crux](https://hexdocs.pm/crux).
