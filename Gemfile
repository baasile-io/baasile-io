source 'https://rubygems.org'
ruby "2.3.1"

gem 'rails',                                    '~> 5.0.0', '>= 5.0.0.1'

# Server
gem 'puma',                                     '~> 3.0'

# Background jobs
gem 'sidekiq',                                  '~> 4.2'

# Databases
gem 'pg',                                       '~> 0.19'
gem 'paper_trail',                              '~> 6.0'

# Monitoring
gem 'newrelic_rpm',                             '~> 3.18'
gem 'airbrake',                                 '~> 5.7'

# Cache store
gem 'redis-rails',                              '~> 5.0'
gem 'redis',                                    '~> 3.3'
gem 'redis-namespace',                          '~> 1.5'

# Security
gem 'rack-attack',                              '~> 5.0'
gem 'easy_captcha',                             '~> 0.6'

# CSS / JS
gem 'sass-rails',                               '~> 5.0'
gem 'font-awesome-sass',                        '~> 4.7'
gem 'bootstrap',                                '~> 4.0.0.alpha6'
gem 'bootstrap-datepicker-rails',               '~> 1.6'
gem 'uglifier',                                 '>= 1.3.0'
gem 'coffee-rails',                             '~> 4.2'
gem 'jquery-rails',                             '~> 4.2'
gem 'i18n-js',                                  '>= 3.0.0.rc15'
gem 'select2-rails',                            '~> 4.0'
## tether positionning for popovers and tooltips
source 'https://rails-assets.org' do
  gem 'rails-assets-tether',                    '>= 1.1.0'
end

# User account
gem 'devise',                                   '~> 4.2'
gem 'devise_security_extension',                '~> 0.9'
gem 'rolify',                                   '~> 5.1'

# Validators
gem 'rails_email_validator',                    '~> 0.1'
gem 'activevalidators',                         '~> 4.0'
gem 'iban-tools',                               '~> 1.1'

# Relation
gem 'ancestry',                                 '~> 2.2'

# Images / PDF
gem 'rmagick',                                  '~> 2.16'
gem 'prawn',                                    '~> 2.2'

# Views helpers
gem 'simple_form',                              '~>3.3.1'
gem 'awesome_print',                            '~> 1.7'

# Encryption
gem 'jwt',                                      '~> 1.5'

# Third-party
gem 'aws-sdk-rails',                            '~> 1.0'

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
