defmodule VancouverImpoundWatch.MixProject do
  use Mix.Project

  def project do
    [
      app: :vancouver_impound_watch,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() == :test do
      [extra_applications: [:logger]]
    else
      [mod: {VancouverImpoundWatch.Application, []}, extra_applications: [:logger]]
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:plug, "~> 1.17"},
      {:req, "~> 0.5.0"},
      {:tzdata, "~> 1.1"}
    ]
  end
end
