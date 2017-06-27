source 'https://rubygems.org'
ruby "2.3.1"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails',                                    '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma',                                     '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails',                               '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier',                                 '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails',                             '~> 4.2'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Monitoring
gem 'newrelic_rpm',                             '~> 3.18'
gem 'airbrake',                                 '~> 5.7'

# Databases
gem 'pg',                                       '~> 0.19'
gem 'paper_trail',                              '~> 6.0'

# Cache store
gem 'redis-rails',                              '~> 5.0'
gem 'redis',                                    '~> 3.3'
gem 'redis-namespace',                          '~> 1.5'

# User account
gem 'devise',                                   '~> 4.2'
gem 'rolify',                                   '~> 5.1'
gem 'devise_security_extension'
gem 'rails_email_validator'
gem 'easy_captcha'
gem 'activevalidators'

# Accountant
gem 'iban-tools'

# Data
gem 'ancestry'
gem 'aws-sdk-rails'
gem 'rmagick'
gem 'prawn'

# Security
gem 'rack-attack'

# Front
gem 'bootstrap',                                '~> 4.0.0.alpha6'
gem 'bootstrap-datepicker-rails'
gem "select2-rails"
gem "i18n-js",                                  '>= 3.0.0.rc15'
gem 'font-awesome-sass'
gem 'simple_form',                              '~>3.3.1'
## tether positionning for popovers and tooltips
source 'https://rails-assets.org' do
  gem 'rails-assets-tether',                    '>= 1.1.0'
end
gem "breadcrumbs_on_rails"
gem 'awesome_print'

# Background jobs
gem 'sidekiq'

# API authentication
gem 'jwt'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Environment variables
  gem 'dotenv-rails'

  # Tests
  gem 'rspec-rails',                            '~> 3.5'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  gem 'webmock'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen',                                 '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen',                  '~> 2.0.0'

  # Intercept mail
  gem 'letter_opener'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
