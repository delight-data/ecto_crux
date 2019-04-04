defmodule EctoCrux do
  @moduledoc """
  Crud concern to use in helper's schema implementation

  usage example:
    For module schema "MyApp.Schema.Film, create a "MyApp.Schema.Films" module with:
    ```
    defmodule MyApp.Schema.Films do
      use EctoCrux, module: MyApp.Schema.Film
    end
    ```
  """

  defmacro __using__(args) do
    quote(bind_quoted: [args: args]) do
      # in caller's context
      @schema_module args[:module]
      @repo args[:repo] || Application.get_all_env(:ecto_crux)[:repo]

      alias Ecto.ULID

      import Ecto.Query, only: [from: 2, where: 2]

      def unquote(:schema_module)() do
        @schema_module
      end

      # returns [Ecto.Schema.t()]
      def unquote(:all)() do
        @repo.all(@schema_module)
      end

      # returns Ecto.Schema.t() | nil
      def unquote(:get!)(id) do
        @repo.get!(@schema_module, id)
      end

      # returns Ecto.Schema.t() | nil
      def unquote(:get)(id) do
        @repo.get(@schema_module, id)
      end

      # returns Ecto.Schema.t()
      def unquote(:create)(attrs \\ %{}) do
        schema = struct(@schema_module)

        schema
        |> @schema_module.changeset(attrs)
        |> @repo.insert()
      end

      # returns Ecto.Schema.t()
      def unquote(:create_if_not_exist)(attrs) do
        blob = get_by(attrs)
        if blob, do: {:ok, blob}, else: create(attrs)
      end

      # returns Ecto.Schema.t()
      def unquote(:create_if_not_exist)(presence_attrs, creation_attrs) do
        blob = get_by(presence_attrs)
        if blob, do: {:ok, blob}, else: create(creation_attrs)
      end

      # returns Ecto.Schema.t()
      def unquote(:update)(blob, attrs) do
        blob
        |> @schema_module.changeset(attrs)
        |> @repo.update()
      end

      # returns {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:delete)(blob) do
        @repo.delete(blob)
      end

      def unquote(:change)(blob, attrs \\ %{}) do
        @schema_module.changeset(blob, attrs)
      end

      # returns Ecto.Schema.t() | nil
      def unquote(:get_by)(clauses, opts \\ []) do
        @repo.get_by(@schema_module, clauses, opts)
      end

      # returns [Ecto.Schema.t()]
      def unquote(:find_by)(filters) do
        @schema_module
        |> where(^filters)
        |> @repo.all()
      end

      # returns Ecto.Schema.t()
      def unquote(:preload)(blob, preloads) do
        blob |> @repo.preload(preloads)
      end

      # returns :integer
      def unquote(:count)() do
        @repo.one(from(b in @schema_module, select: fragment("count(*)")))
      end
    end
  end
end
