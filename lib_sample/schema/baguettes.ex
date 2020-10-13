defmodule EctoCrux.Schema.Baguettes do
  @moduledoc """
    Sample module using EctoCrux

    ```
    defmodule MyApp.Schema.Baguettes do
      use EctoCrux, module: MyApp.Schema.Baguette
    end
    ```
  """

  use EctoCrux, module: EctoCrux.Schema.Baguette

  require EctoCrux.Repo
end
