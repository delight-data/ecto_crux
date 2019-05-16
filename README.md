# EctoCrux

Crud concern to use in helper's schema implementation with Repo methods.
Replace methods generated with `mix phx.gen.schema`.

Hex documentation: [here](https://hexdocs.pm/ecto_crux/EctoCrux.html#content)

## Guide usage

#### Installation

```elixir
def deps do
  [
    {:ecto_crux, "~> 1.1.0"}
  ]
end
```

#### configuration

```elixir
config :ecto_crux, repo: MyApp.Repo
```

#### usage example
From a schema module `MyApp.Schema.Baguette`, create a `MyApp.Schema.Baguettes` module containing:

```elixir
defmodule MyApp.Schema.Baguettes do
  use EctoCrux, module: MyApp.Schema.Baguette

  # This module is also the perfect place to implement all your custom accessors/operations arround this schema.
  # This allows you to have all your query/repo code centralized in one file, keeping your code-base clean.
end
```


## ideas:
  pluck (?)
  count(filter)

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/crux](https://hexdocs.pm/crux).
