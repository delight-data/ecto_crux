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

  parameters are:
  - :repo : specify repo to use to handle this queryable module
  - [optional] :page_size : default page size to use when using pagination if page_size is not specified

  #### tl;dr; usage example


  ```elixir
  defmodule MyApp.Schema.Baguette do
    use Ecto.Schema
    import Ecto.Changeset

    schema "baguettes" do
      field(:name, :string)
      field(:kind, :string)
    end

    def changeset(user, params \\ %{}) do
      user
      |> cast(params, [:name])
      |> validate_required([:name])
    end
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

  then to get all baguettes
  ```
    baguettes = MyApp.Schema.Baguettes.all()
  ```

  You are good to go !

  Functions you can now uses with MyApp.Schema.Baguettes are available [here](EctoCrux.Schema.Baguettes.html#content)

  """

  defmacro __using__(args) do
    quote(bind_quoted: [args: args]) do
      @schema_module args[:module]
      @repo args[:repo] || Application.get_all_env(:ecto_crux)[:repo]
      @page_size args[:page_size] ||
                   Application.get_all_env(:ecto_crux)[:page_size] || 50

      import Ecto.Query,
        only: [from: 1, from: 2, where: 2, offset: 2, limit: 2, exclude: 2, select: 2]

      alias Ecto.{Query, Queryable}

      @doc false
      def unquote(:schema_module)(), do: @schema_module

      @doc false
      def unquote(:repo)(), do: @repo

      @doc false
      def unquote(:page_size)(), do: @page_size

      @doc false
      def unquote(:change)(blob, attrs \\ %{}), do: @schema_module.changeset(blob, attrs)

      @doc false
      # eq: from e in @schema_module
      def init_query(), do: @schema_module |> Ecto.Queryable.to_query()

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
        |> @repo.insert(clean_opts(opts))
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
        @schema_module
        |> @repo.get(id, clean_opts(opts))
        |> build_preload(opts[:preloads])
      end

      @spec get!(id :: term) :: @schema_module.t() | nil
      def unquote(:get!)(id), do: get!(id, [])

      @spec get!(id :: term, opts :: Keyword.t()) :: @schema_module.t() | nil
      def unquote(:get!)(id, opts) do
        @schema_module
        |> @repo.get!(id, clean_opts(opts))
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
        @schema_module
        |> @repo.get_by(clauses, clean_opts(opts))
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

      def unquote(:find_by)(%Ecto.Query{} = query) do
        query
        |> find_by([])
      end

      def unquote(:find_by)(filters, opts) when is_list(filters) do
        query =
          @schema_module
          |> where(^filters)
          |> find_by(opts)
      end

      def unquote(:find_by)(%Ecto.Query{} = query, opts) when is_map(opts) do
        query
        |> find_by(to_keyword(opts))
      end

      def unquote(:find_by)(%Ecto.Query{} = query, opts) do
        map_opts = to_map(opts)

        {pagination, query} =
          query
          |> filter_away_delete_if_requested(map_opts)
          |> only_delete_if_requested(map_opts)
          |> crux_paginate(map_opts)

        entries =
          query
          |> @repo.all(clean_opts(opts))
          |> ensure_typed_list()

        case pagination do
          :no_pagination ->
            entries

          :has_pagination ->
            total_entries = count(query, opts)
            page_size = crux_page_size(map_opts)

            %EctoCrux.Page{
              entries: entries,
              page: Keyword.get(opts, :page, 1),
              page_size: page_size,
              total_entries: total_entries,
              total_pages: crux_total_pages(total_entries, page_size)
            }
        end
      end

      @spec find_by(filters :: Keyword.t() | map(), opts :: map()) :: [@schema_module.t()]
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
      def unquote(:all)(), do: all([])

      @doc """
      [Repo] Fetches all entries from the data store matching using opts

          # Fetch all french Baguettes
          Baguettes.all(prefix: "francaise")
      """
      @spec all(opts :: Keyword.t()) :: [@schema_module.t()]
      def unquote(:all)(opts) when is_list(opts) do
        map_opts = to_map(opts)
        # todo: pagi option
        init_query()
        |> filter_away_delete_if_requested(map_opts)
        |> only_delete_if_requested(map_opts)
        |> @repo.all(clean_opts(opts))
        |> ensure_typed_list()
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
        map_opts = to_map(opts)

        @schema_module
        |> where(^filters)
        |> filter_away_delete_if_requested(map_opts)
        |> only_delete_if_requested(map_opts)
        |> @repo.stream(clean_opts(opts))
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
        |> @repo.update(clean_opts(opts))
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

      # idea: delete all, soft delete using ecto_soft_delete

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
        |> @repo.one(clean_opts(opts))
      end

      @doc """
      Count number of elements

          baguettes_count = Baguettes.count()
      """

      @spec count(query :: Ecto.Query.t()) :: integer()
      def unquote(:count)(%Ecto.Query{} = query) do
        count(query, [])
      end

      @spec count(query :: Ecto.Query.t(), opts :: Keyword.t()) :: integer()
      def unquote(:count)(%Ecto.Query{} = query, opts) do
        query
        |> exclude(:preload)
        |> exclude(:order_by)
        |> exclude(:select)
        |> select(count("*"))
        |> @repo.one(clean_opts(opts))
      end

      @spec count(opts :: Keyword.t()) :: integer()
      def unquote(:count)(opts) when is_map(opts) do
        init_query()
        |> count(opts)
      end

      @spec count() :: integer()
      def unquote(:count)() do
        init_query()
        |> count()
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

      defp to_map(list) when is_list(list), do: list |> Enum.into(%{})
      defp to_map(map) when is_map(map), do: map

      # remove all keys used by crux before being given to Repo
      defp clean_opts(opts) when is_list(opts),
        do: Keyword.drop(opts, [:exclude_deleted, :only_deleted, :offset, :page, :page_size])

      # soft delete (if you use ecto_soft_delete on the field deleted_at)
      defp filter_away_delete_if_requested(
             %Ecto.Query{} = query,
             %{exclude_deleted: true} = opts
           ),
           do: from(e in query, where: is_nil(e.deleted_at))

      defp filter_away_delete_if_requested(%Ecto.Query{} = query, %{} = opts), do: query

      defp only_delete_if_requested(%Ecto.Query{} = query, %{only_deleted: true} = opts),
        do: from(e in query, where: not is_nil(e.deleted_at))

      defp only_delete_if_requested(%Ecto.Query{} = query, %{} = opts), do: query

      # pagination
      defp crux_paginate(%Ecto.Query{} = query, %{page: page} = opts)
           when is_integer(page) and page > 0 do
        page_size = crux_page_size(opts)
        do_crux_paginate(query, page_size * (page - 1), opts)
      end

      defp crux_paginate(%Ecto.Query{} = query, %{offset: offset} = opts)
           when is_integer(offset) and offset >= 0,
           do: do_crux_paginate(query, offset, opts)

      defp crux_paginate(%Ecto.Query{} = query, %{} = _opts), do: {:no_pagination, query}

      defp do_crux_paginate(%Ecto.Query{} = query, offset, opts) do
        page_size = crux_page_size(opts)

        query =
          query
          |> offset(^offset)
          |> limit(^page_size)

        {:has_pagination, query}
      end

      defp crux_page_size(opts) when is_map(opts), do: Map.get(opts, :page_size, @page_size)

      defp crux_total_pages(0, _), do: 1

      defp crux_total_pages(total_entries, page_size),
        do: (total_entries / page_size) |> Float.ceil() |> round()
    end
  end
end
