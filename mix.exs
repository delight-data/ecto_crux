defmodule EctoCrux.MixProject do
  use Mix.Project

  @version "1.2.16"

  def project do
    [
      app: :ecto_crux,
      name: "EctoCrux",
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Generate basics and common repo calls within your schema implementation",
      deps: deps(),
      package: package(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/delight-data/ecto_crux"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:ecto_sql, "~> 3.5", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      release: [
        "cmd git tag v#{@version}",
        "cmd git push origin master",
        "cmd git push --tags",
        "hex.publish --yes",
        "cmd rm -rf doc"
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib_sample", "lib"]
  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(:test), do: ["lib_sample", "lib", "test"]
end
