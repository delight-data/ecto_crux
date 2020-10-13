defmodule EctoCrux do
  @moduledoc """
  Crud concern to use in helper's schema implementation with common Repo methods.
  Replace methods generated with `mix phx.gen.schema`.

  ## Getting started
  #### Installation

  ```elixir
  def deps do
    [
      {:ecto_crux, "~> 1.1.5"}
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

  You are good to go !

  Functions you can now uses with MyApp.Schema.Baguettes are available [here](EctoCrux.Schema.Baguettes.html#content)

  """

  defmacro __using__(args) do
    quote(bind_quoted: [args: args]) do
      # in caller's context
      @schema_module args[:module]
      @repo args[:repo] || Application.get_all_env(:ecto_crux)[:repo]

      alias Ecto.ULID

      import Ecto.Query, only: [from: 2, where: 2, limit: 2]

      def unquote(:schema_module)() do
        @schema_module
      end

      @doc """
      [Repo] Fetches all entries from the data store.

          # Fetch all Baguettes
          Baguettes.all()
      """
      @spec all() :: [Ecto.Schema.t()]
      def unquote(:all)() do
        @repo.all(@schema_module)
      end

      @doc """
      [Repo] Fetches all entries from the data store matching using opts

          # Fetch all french Baguettes
          Baguettes.all(prefix: "francaise")
      """
      @spec all(opts :: Keyword.t()) :: [Ecto.Schema.t()]
      def unquote(:all)(opts) do
        @repo.all(@schema_module, opts)
      end

      @doc """
      [Repo] Fetches a single struct from the data store where the primary key matches the given id.

          # Get the baguette with id primary key `01DACBCR6REMDH6446VCQEZ5EC`
          Baguettes.get("01DACBCR6REMDH6446VCQEZ5EC")

          # Get the baguette with id primary key `01DACBCR6REMDH6446VCQEZ5EC` and preload it's bakery and flavor
          Baguettes.get("01DACBCR6REMDH6446VCQEZ5EC", preloads: [:bakery, :flavor])

      note: preloads option is an crux additional feature
      """
      @spec get(id :: term, opts :: Keyword.t()) :: Ecto.Schema.t() | nil
      def unquote(:get)(id, opts \\ []) do
        @repo.get(@schema_module, id, opts)
        |> build_preload(opts[:preloads])
      end

      defp build_preload(blob, nil), do: blob
      defp build_preload(blob, []), do: blob
      defp build_preload(blob, preloads), do: preload(blob, preloads)

      @doc """
      Similar to get/1 but ignore record if column :deleted_at is not nil
      This is very useful if you use soft_delete features
      """
      @spec get_undeleted(id :: term, opts :: Keyword.t()) :: Ecto.Schema.t() | nil
      def unquote(:get_undeleted)(id, opts \\ []) do
        query = from(e in @schema_module, where: e.id == ^id, where: is_nil(e.deleted_at))

        query
        |> @repo.one()
        |> build_preload(opts[:preloads])
      end

      @doc """
      [Repo] Similar to get/2 but raises Ecto.NoResultsError if no record was found.

          # Get the baguette with id primary key `01DACBCR6REMDH6446VCQEZ5EC`
          Baguettes.get!("01DACBCR6REMDH6446VCQEZ5EC")
      """
      @spec get!(id :: term, opts :: Keyword.t()) :: Ecto.Schema.t() | nil
      def unquote(:get!)(id, opts \\ []) do
        @repo.get!(@schema_module, id, opts)
      end

      if function_exported?(@repo, :insert, 1) do
        @doc """
        [Repo] Create (insert) a new baguette from attrs

            # Create a new baguette with `:kind` value set to `:tradition`
            {:ok, baguette} = Baguettes.create(%{kind: :tradition})
        """
        @spec create(attrs :: map()) :: {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        def unquote(:create)(attrs \\ %{}) do
          schema = struct(@schema_module)

          schema
          |> @schema_module.changeset(attrs)
          |> @repo.insert()
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
                {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        def unquote(:create_if_not_exist)(attrs) do
          create_if_not_exist(attrs, attrs)
        end

        @doc """
        [Repo] Create (insert) a baguette from attrs if it doesn't exist

        Like `create_if_not_exist/1` but you can specify attrs for the presence test, and creation attrs.
        """
        @spec create_if_not_exist(presence_attrs :: map(), creation_attrs :: map()) ::
                {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        def unquote(:create_if_not_exist)(presence_attrs, creation_attrs) do
          blob = exist?(presence_attrs)
          if blob, do: {:ok, blob}, else: create(creation_attrs)
        end
      end

      @doc """
      Test if an object with <presence_attrs> exist
      """
      @spec exist?(presence_attrs :: map()) :: Ecto.Schema.t() | nil
      def unquote(:exist?)(presence_attrs) do
        # convert to Keylist
        presence_attrs = Enum.reduce(presence_attrs, [], fn {k, v}, acc -> [{k, v} | acc] end)

        @schema_module
        |> where(^presence_attrs)
        |> limit(1)
        |> @repo.all()
        |> Enum.at(-1)
      end

      if function_exported?(@repo, :update, 1) do
        @doc """
        [Repo] Updates a changeset using its primary key.

            {:ok, updated_baguette} = Baguettes.update(baguette, %{kind: :best})
        """
        @spec update(blob :: Ecto.Schema.t(), attrs :: map(), opts :: Keyword.t()) ::
                {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        def unquote(:update)(blob, attrs, opts \\ []) do
          blob
          |> @schema_module.changeset(attrs)
          |> @repo.update()
        end
      end

      if function_exported?(@repo, :delete, 2) do
        @doc """
        [Repo] Deletes a struct using its primary key.

            {:ok, deleted_baguette} = Baguettes.delete(baguette)
        """
        @spec delete(blob :: Ecto.Schema.t(), opts :: Keyword.t()) ::
                {:ok, Ecto.Schema.t()} | {:error, Ecto.Changeset.t()}
        def unquote(:delete)(blob, opts \\ []) do
          @repo.delete(blob, opts)
        end
      end

      # delete all

      @doc false
      def unquote(:change)(blob, attrs \\ %{}) do
        @schema_module.changeset(blob, attrs)
      end

      @doc """
      [Repo] Fetches a single result from the clauses.

          best_baguette = Baguettes.get_by(kind: :best)
      """
      @spec get_by(clauses :: Keyword.t() | map(), opts :: Keyword.t()) :: Ecto.Schema.t() | nil
      def unquote(:get_by)(clauses, opts \\ []) do
        @repo.get_by(@schema_module, clauses, opts)
      end

      @doc """
      Similar to get_by/1 but ignore record if column :deleted_at is not nil
      This is very useful if you use soft_delete features

          best_baguette = Baguettes.get_undeleted_by(kind: :best)
      """
      @spec get_undeleted_by(clauses :: Keyword.t() | map()) :: Ecto.Schema.t() | nil
      def unquote(:get_undeleted_by)(clauses) when is_map(clauses) do
        clauses
        |> Enum.map(fn {k, v} -> {k, v} end)
        |> get_undeleted_by()
      end

      def unquote(:get_undeleted_by)(filters) when is_list(filters) do
        query = from(e in @schema_module, where: ^filters, where: is_nil(e.deleted_at))

        query
        |> @repo.one()
      end

      @doc """
      [Repo] Fetches all results from the clauses.

          best_baguettes = Baguettes.find_by(kind: :best)
      """
      @spec find_by(filters :: Keyword.t() | map()) :: [Ecto.Schema.t()]

      def unquote(:find_by)(filters) when is_map(filters) do
        filters
        |> Enum.map(fn {k, v} -> {k, v} end)
        |> find_by()
      end

      def unquote(:find_by)(filters) when is_list(filters), do: find_by(filters, [])

      def unquote(:find_by)(filters, opts) when is_list(filters) do
        @schema_module
        |> where(^filters)
        |> @repo.all(opts)
      end

      @spec find_by(filters :: Keyword.t() | map(), opts :: Keyword.t()) :: [Ecto.Schema.t()]
      def unquote(:find_by)(filters, opts) when is_map(filters) do
        filters
        |> Enum.map(fn {k, v} -> {k, v} end)
        |> find_by(opts)
      end

      @doc """
      Similar to find_by/1 but ignore record if column :deleted_at is not nil
      This is very useful if you use soft_delete features

          best_baguettes = Baguettes.find_by(kind: :best)
      """
      @spec find_undeleted_by(filters :: Keyword.t() | map()) :: [Ecto.Schema.t()]
      def unquote(:find_undeleted_by)(filters) when is_map(filters) do
        filters
        |> Enum.map(fn {k, v} -> {k, v} end)
        |> find_undeleted_by()
      end

      def unquote(:find_undeleted_by)(filters) when is_list(filters) do
        query = from(e in @schema_module, where: ^filters, where: is_nil(e.deleted_at))

        query
        |> @repo.all()
      end

      @doc """
      Little helper to pick first record

          first_baguette = Baguettes.first()
      """
      @spec first() :: Ecto.Schema.t()
      def unquote(:first)() do
        @schema_module
        |> first()
        |> @repo.one()
      end

      @doc """
      Little helper to pick first records

          first_baguettes = Baguettes.first(42)
      """
      @spec first(count :: term) :: [Ecto.Schema.t()]
      def unquote(:first)(count) do
        query = from(e in @schema_module, order_by: [desc: e.id], limit: ^count)

        query
        |> @repo.all()
      end

      @doc """
      Little helper to pick last record. the last baguette is always the best !

          last_baguette = Baguettes.last()
      """
      @spec last() :: Ecto.Schema.t()
      def unquote(:last)() do
        @schema_module
        |> last()
        |> @repo.one()
      end

      @doc """
      Little helper to pick last records.

          last_baguettes = Baguettes.last(42)
      """
      @spec last(count :: term) :: [Ecto.Schema.t()]
      def unquote(:last)(count) do
        query = from(e in @schema_module, order_by: [asc: e.id], limit: ^count)

        query
        |> @repo.all()
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
      @spec stream(filters :: Keyword.t() | map()) :: Enum.t()
      def unquote(:stream)(filters \\ []) do
        @repo.stream(from(b in @schema_module, where: ^filters))
      end

      @doc """
      [Repo] Preloads all associations on the given struct or structs.

          my_baguette = Baguettes.preload(baguette, [:floor, :boulanger])
      """
      @spec preload(structs_or_struct_or_nil, preloads :: term(), opts :: Keyword.t()) ::
              structs_or_struct_or_nil
            when structs_or_struct_or_nil: [Ecto.Schema.t()] | Ecto.Schema.t() | nil
      def unquote(:preload)(blob, preloads, opts \\ []) do
        blob |> @repo.preload(preloads, opts)
      end

      @doc """
      Count number of elements

          baguettes_count = Baguettes.count()
      """
      @spec count() :: integer()
      def unquote(:count)() do
        @repo.one(from(b in @schema_module, select: fragment("count(*)")))
      end

      @spec count(opts :: Keyword.t()) :: integer()
      def unquote(:count)(opts) do
        @repo.one(from(b in @schema_module, select: fragment("count(*)")), opts)
      end
    end
  end
end
