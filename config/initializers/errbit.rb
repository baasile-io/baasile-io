Airbrake.configure do |config|
  config.environment = Rails.env
  config.ignore_environments = %w(development test)
  config.project_id = ENV['ERRBIT_PROJECT_ID'].to_i
  config.project_key = ENV['ERRBIT_PROJECT_KEY']
  config.host    = ENV['ERRBIT_HOST']
  config.port    = ENV['ERRBIT_PORT'].to_i
  config.secure  = config.port == 443
end
