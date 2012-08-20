rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis_options = {host: uri.host, port: uri.port, password: uri.password, thread_safe: true}
  Resque.redis = Redis.new redis_options
  Resque.after_fork do |job|
    Resque.redis = Redis.new redis_options
  end
else
  resque_config = YAML.load_file(rails_root + '/config/resque.yml')
  Resque.redis = resque_config[rails_env]
end


# Re-established dropped MySQL connections -- long-lived workers sometimes
# drop connections
Resque.after_fork = Proc.new {
  ActiveRecord::Base.verify_active_connections!
}

# load in the server so we can mount it at /resque in routes.rb
require 'resque/server'
require 'resque/status_server'
