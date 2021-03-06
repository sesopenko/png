defmodule Sesopenko.PNG.MixProject do
  use Mix.Project

  def project do
    [
      app: :sesopenko_png,
      version: "1.0.4",
      description: description(),
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  defp description() do
    "A PNG bitstring generator. Takes an two-dimensional List set of greyscale byte vales and generates a bitstring."
  end

  defp package() do
    [
      name: "sesopenko_png",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["GNU-GPLv3"],
      links: %{"GitHub" => "https://github.com/sesopenko/png"},
      source_url: "https://github.com/sesopenko/png/blob/master/"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # used for converting wikipedia example png to byte string.
      {:hexate, ">= 0.6.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
