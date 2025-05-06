import Config

if config_env() == :test do
  config :logger,
    level: :warning

  config :vancouver_impound_watch,
    req_options: [plug: {Req.Test, VancouverImpoundWatch.Fetcher}]
end

config :vancouver_impound_watch, VancouverImpoundWatch.Scheduler, fetch_interval_secs: 3600
