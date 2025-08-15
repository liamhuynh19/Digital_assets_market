require "sidekiq"
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDISCLOUD_URL") { "redis://localhost:6379/1" } }
  config.logger = ActiveSupport::Logger.new(Rails.root.join("log", "sidekiq.log"))
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDISCLOUD_URL") { "redis://localhost:6379/1" } }
end
