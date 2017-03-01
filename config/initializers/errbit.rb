Airbrake.configure do |config|
  config.development_environments = ['development', 'test']
  config.user_attributes = [:id, :email]
  config.project_id = ENV['ERRBIT_PROJECT_ID'].to_i
  config.api_key = ENV['ERRBIT_API_KEY']
  config.host    = ENV['ERRBIT_HOST']
  config.port    = ENV['ERRBIT_PORT'].to_i
  config.secure  = config.port == 443
end
