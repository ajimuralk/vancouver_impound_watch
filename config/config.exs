import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :logger, :console, format: "$time $metadata[$level] $message\n"
