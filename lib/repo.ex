defmodule EctoCrux.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :activation,
    adapter: Ecto.Adapters.Postgres

  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, "localhost")}
  end
end
