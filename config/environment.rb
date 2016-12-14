# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => ENV['SENDGRID_USERNAME'],
  :password => ENV['SENDGRID_PASSWORD'],
  :domain => ENV['BAASILE_IO_HOSTNAME'],
  :address => ENV['BAASILE_IO_MAILER_SMTP'],
  :port => ENV['BAASILE_IO_MAILER_PORT'].to_i,
  :authentication => :plain,
  :enable_starttls_auto => true
}
