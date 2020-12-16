defmodule EctoCrux do
  @moduledoc """
  Crud concern to use in helper's schema implementation with common Repo methods.
  Replace methods generated with `mix phx.gen.schema`.

  ## Getting started
  #### Installation

  ```elixir
  def deps do
    [
      {:ecto_crux, "~> 1.2.0"}
    ]
  end
  ```

  #### configuration (config.exs)

  ```elixir
  config :ecto_crux, repo: MyApp.Repo
  ```

  #### tl;dr; usage example


  ```elixir
  defmodule MyApp.Schema.Baguette do

  end
  ```

  ```elixir
  defmodule MyApp.Schema.Baguettes do
    use EctoCrux, module: MyApp.Schema.Baguette

    # This module is also the perfect place to implement all
    # your custom accessors/operations arround this schema.
    # This allows you to have all your query/repo code
    # centralized in one file, keeping your code-base clean.
  end
  ```

  then
  ```


  ```


  You are good to go !

  Functions you can now uses with MyApp.Schema.Baguettes are available [here](EctoCrux.Schema.Baguettes.html#content)

  """

  defmacro __using__(args) do
    quote(bind_quoted: [args: args]) do
      @schema_module args[:module]
      @repo args[:repo] || Application.get_all_env(:ecto_crux)[:repo]

      # list of option than can be used in repo (@see https://hexdocs.pm/ecto/Ecto.Repo.html#module-shared-options)
      # @repo_options [:prefix, :returning, :force, :timeout, :log, :telemetry_event, :telemetry_options] ...
      # pick mines, give other to repo

      import Ecto.Query, only: [from: 2, where: 2, limit: 2]

      alias Ecto.{
        Query,
        Queryable,
        ULID
      }

      def unquote(:schema_module)(), do: @schema_module

      def unquote(:repo)(), do: @repo

      @doc false
      def unquote(:change)(blob, attrs \\ %{}) do
        @schema_module.changeset(blob, attrs)
      end

      ######################################################################################
      # CREATE ONE

      @doc """
      [Repo] Create (insert) a new baguette from attrs

          # Create a new baguette with `:kind` value set to `:tradition`
          {:ok, baguette} = Baguettes.create(%{kind: :tradition})
      """
      @spec create(attrs :: map(), opts :: Keyword.t()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:create)(attrs \\ %{}, opts \\ []) do
        %@schema_module{}
        |> @schema_module.changeset(attrs)
        |> @repo.insert(opts)
      end

      @doc """
      [Repo] Create (insert) a baguette from attrs if it doesn't exist

          # Create a new baguette with `:kind` value set to `:tradition`
          baguette = Baguettes.create(%{kind: :tradition})
          # Create another one with the same kind
          {:ok, another_ baguette} = Baguettes.create_if_not_exist(%{kind: :tradition})
          # `baguette` and `another_baguette` are the same `Baguette`
      """
      @spec create_if_not_exist(attrs :: map()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:create_if_not_exist)(attrs), do: create_if_not_exist(attrs, attrs)

      @doc """
      [Repo] Create (insert) a baguette from attrs if it doesn't exist

      Like `create_if_not_exist/1` but you can specify options (like prefix) to give to ecto
      """
      @spec create_if_not_exist(attrs :: map(), opts :: Keyword.t()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:create_if_not_exist)(attrs, opts) when is_list(opts),
        do: create_if_not_exist(attrs, attrs, opts)

      @doc """
      [Repo] Create (insert) a baguette from attrs if it doesn't exist

      Like `create_if_not_exist/1` but you can specify attrs for the presence test, and creation attrs.
      """
      @spec create_if_not_exist(presence_attrs :: map(), creation_attrs :: map()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:create_if_not_exist)(presence_attrs, creation_attrs)
          when is_map(creation_attrs),
          do: create_if_not_exist(presence_attrs, creation_attrs, [])

      @doc """
      [Repo] Create (insert) a baguette from attrs if it doesn't exist

      Like `create_if_not_exist/1` but you can specify attrs for the presence test, and creation attrs.
      """
      @spec create_if_not_exist(
              presence_attrs :: map(),
              creation_attrs :: map(),
              opts :: Keyword.t()
            ) :: {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:create_if_not_exist)(presence_attrs, creation_attrs, opts)
          when is_map(creation_attrs) and is_list(opts) do
        blob = exist?(presence_attrs, opts)
        if blob, do: {:ok, blob}, else: create(creation_attrs, opts)
      end

      ######################################################################################
      # READ ONE

      @doc """
      [Repo] Fetches a single struct from the data store where the primary key matches the given id.

          # Get the baguette with id primary key `01DACBCR6REMDH6446VCQEZ5EC`
          Baguettes.get("01DACBCR6REMDH6446VCQEZ5EC")
      """
      @spec get(id :: term) :: @schema_module.t() | nil
      def unquote(:get)(id), do: get(id, [])

      @doc """
      [Repo] Fetches a single struct from the data store where the primary key matches the given id.

          # Get the baguette with id primary key `01DACBCR6REMDH6446VCQEZ5EC` and preload it's bakery and flavor
          Baguettes.get("01DACBCR6REMDH6446VCQEZ5EC", preloads: [:bakery, :flavor])

      note: preloads option is an crux additional feature
      """
      @spec get(id :: term, opts :: Keyword.t()) :: @schema_module.t() | nil
      def unquote(:get)(id, opts) do
        # todo: exclude_deleted option
        @schema_module
        |> @repo.get(id, opts)
        |> build_preload(opts[:preloads])
      end

      @doc """
      [Repo] Fetches a single result from the clauses.

          best_baguette = Baguettes.get_by(kind: :best)
      """
      @spec get_by(clauses :: Keyword.t() | map()) :: @schema_module.t() | nil
      def unquote(:get_by)(clauses), do: get_by(clauses, [])

      @doc """
      [Repo] Fetches a single result from the clauses.

          best_baguette = Baguettes.get_by(kind: :best)
      """
      @spec get_by(clauses :: Keyword.t() | map(), opts :: Keyword.t()) ::
              @schema_module.t() | nil
      def unquote(:get_by)(clauses, opts) do
        # todo: exclude_deleted option
        @schema_module
        |> @repo.get_by(clauses, opts)
        |> build_preload(opts[:preloads])
      end

      ######################################################################################
      # READ MULTI

      @doc """
      [Repo] Fetches all results from the clauses.

          best_baguettes = Baguettes.find_by(kind: :best)
      """
      @spec find_by(filters :: Keyword.t() | map()) :: [@schema_module.t()]

      def unquote(:find_by)(filters) when is_map(filters) do
        filters
        |> to_keyword()
        |> find_by()
      end

      def unquote(:find_by)(filters) when is_list(filters), do: find_by(filters, [])

      def unquote(:find_by)(filters, opts) when is_list(filters) do
        # todo: exclude_deleted option   query = from(e in @schema_module, where: ^filters, where: is_nil(e.deleted_at))
        # todo: pagi option

        @schema_module
        |> where(^filters)
        |> @repo.all(opts)
      end

      @spec find_by(filters :: Keyword.t() | map(), opts :: Keyword.t()) :: [@schema_module.t()]
      def unquote(:find_by)(filters, opts) when is_map(filters) do
        filters
        |> to_keyword()
        |> find_by(opts)
      end

      @doc """
      [Repo] Fetches all entries from the data store.

          # Fetch all Baguettes
          Baguettes.all()
      """
      @spec all() :: [@schema_module.t()]
      def unquote(:all)() do
        @repo.all(@schema_module)
      end

      @doc """
      [Repo] Fetches all entries from the data store matching using opts

          # Fetch all french Baguettes
          Baguettes.all(prefix: "francaise")
      """
      @spec all(opts :: Keyword.t()) :: [@schema_module.t()]
      def unquote(:all)(opts) when is_list(opts) do
        # todo: exclude_deleted option
        # todo: pagi option
        @repo.all(@schema_module, opts)
      end

      @doc """
      Like `find_by/1` by returns a stream to handle large requests

          Repo.transaction(fn ->
            Baguettes.stream(kind: :best)
            |> Stream.chunk_every(@chunk_size)
            |> Stream.each(fn baguettes_chunk ->
              # eat them
            end)
            |> Stream.run()
          end)

      """
      @spec stream(filters :: Keyword.t(), opts :: Keyword.t()) :: Enum.t()
      def unquote(:stream)(filters, opts \\ []) do
        # todo: exclude_deleted option
        @repo.stream(from(b in @schema_module, where: ^filters), opts)
      end

      ######################################################################################
      # UPDATE

      @doc """
      [Repo] Updates a changeset using its primary key.

          {:ok, updated_baguette} = Baguettes.update(baguette, %{kind: :best})
      """
      @spec update(blob :: @schema_module.t(), attrs :: map(), opts :: Keyword.t()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:update)(blob, attrs, opts \\ []) do
        blob
        |> @schema_module.changeset(attrs)
        |> @repo.update(opts)
      end

      ######################################################################################
      # DELETE

      @doc """
      [Repo] Deletes a struct using its primary key.

          {:ok, deleted_baguette} = Baguettes.delete(baguette)
      """
      @spec delete(blob :: @schema_module.t(), opts :: Keyword.t()) ::
              {:ok, @schema_module.t()} | {:error, Ecto.Changeset.t()}
      def unquote(:delete)(blob, opts \\ []), do: @repo.delete(blob, opts)

      # idea: delete all, soft delete

      ######################################################################################
      # SUGAR

      @doc """
      [Repo] Preloads all associations on the given struct or structs.

          my_baguette = Baguettes.preload(baguette, [:floor, :boulanger])
      """
      @spec preload(structs_or_struct_or_nil, preloads :: term(), opts :: Keyword.t()) ::
              structs_or_struct_or_nil
            when structs_or_struct_or_nil: [@schema_module.t()] | @schema_module.t() | nil
      def unquote(:preload)(blob, preloads, opts \\ []) do
        blob |> @repo.preload(preloads, opts)
      end

      @doc """
      Test if an object with <presence_attrs> exist
      """
      @spec exist?(presence_attrs :: map(), opts :: Keyword.t()) :: @schema_module.t() | nil
      def unquote(:exist?)(presence_attrs, opts \\ []) do
        presence_attrs = to_keyword(presence_attrs)

        @schema_module
        |> where(^presence_attrs)
        |> limit(1)
        |> @repo.all(opts)
        |> Enum.at(-1)
      end

      @doc """
      Little helper to pick first record

          first_baguette = Baguettes.first()
      """
      @spec first() :: @schema_module.t()
      def unquote(:first)(), do: first(1)

      @doc """
      Little helper to pick first records

          first_baguettes = Baguettes.first(42)
      """
      @spec first(count :: term) :: [@schema_module.t()]
      def unquote(:first)(count) when is_integer(count) do
        query = from(e in @schema_module, order_by: [desc: e.id], limit: ^count)

        query
        |> @repo.all()
      end

      @doc """
      Little helper to pick last record. the last baguette is always the best !

          last_baguette = Baguettes.last()
      """
      @spec last() :: @schema_module.t()
      def unquote(:last)(), do: last(1)

      @doc """
      Little helper to pick last records.

          last_baguettes = Baguettes.last(42)
      """
      @spec last(count :: term) :: [@schema_module.t()]
      def unquote(:last)(count) when is_integer(count) do
        query = from(e in @schema_module, order_by: [asc: e.id], limit: ^count)

        query
        |> @repo.all()
      end

      @doc """
      Count number of elements

          baguettes_count = Baguettes.count()
      """
      @spec count() :: integer()
      def unquote(:count)(), do: count([])

      @spec count(opts :: Keyword.t()) :: integer()
      def unquote(:count)(opts) do
        @repo.one(from(b in @schema_module, select: fragment("count(*)")), opts)
      end

      ######################################################################################
      # PRIVATE

      defp ensure_typed_list(items) do
        case items do
          [%@schema_module{} = _ | _] -> items
          _ -> []
        end
      end

      defp build_preload(blob, nil), do: blob
      defp build_preload(blob, []), do: blob
      defp build_preload(blob, preloads), do: preload(blob, preloads)

      defp to_keyword(map) when is_map(map), do: map |> Enum.map(fn {k, v} -> {k, v} end)
      defp to_keyword(list) when is_list(list), do: list
    end
  end
end
