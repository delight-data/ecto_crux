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

  # To ensure that EctoCrux.Repo is compiled before EctoCrux.Schema.Baguettes.
  # It is therefore specific to the Baguettes example integrated in Crux.
  # Without this line, the compilation of EctoCrux.Repo comes too late since
  # here we are not really in the global context of a Phoenix project.
  require EctoCrux.Repo
end
