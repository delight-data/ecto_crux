defmodule EctoCrux.Page do
  @moduledoc """
    heavily inspired from scrivener

    https://github.com/drewolson/scrivener_ecto
    using https://github.com/drewolson/scrivener

    source: https://github.com/drewolson/scrivener/blob/master/lib/scrivener/page.ex

    A `EctoCrux.Page` has 5 fields that can be accessed: `entries`, `page`, `page_size`, `total_entries` and `total_pages`.
      page.entries
      page.page
      page.page_size
      page.total_entries
      page.total_pages


    I hesitate a LOT between:
    - use the sell made scrivener that does the job (my default choice)
    - do my version (smaller) to get the win of having a simple pagination feature

    I did my own because:
    - scrivener is now in low maintenance mode
    - I don't want to force a crux user to have another dependency
    - it is not a lot of lines of code
  """

  defstruct [:page, :page_size, :total_entries, :total_pages, entries: []]

  @type t :: %__MODULE__{
          entries: list(),
          page: pos_integer(),
          page_size: integer(),
          total_entries: integer(),
          total_pages: pos_integer()
        }
end
