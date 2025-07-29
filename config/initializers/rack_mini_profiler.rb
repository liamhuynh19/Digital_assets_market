if Rails.env.development?
  Rack::MiniProfiler.config.position = "top-right"
  Rack::MiniProfiler.config.start_hidden = false
end
