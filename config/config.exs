import Config

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :vancouver_impound_watch,
  req_options: [
    plug: {Req.Test, VancouverImpoundWatch.Fetcher}
  ]
