source 'https://rubygems.org'
ruby "2.3.1"

gem 'rails',                                    '~> 5.0.0', '>= 5.0.0.1'

# Server
gem 'puma',                                     '~> 3.6.2'

# Background jobs
gem 'sidekiq',                                  '~> 4.2.7'

# Databases
gem 'pg',                                       '~> 0.19.0'
gem 'paper_trail',                              '~> 6.0.2'

# Monitoring
gem 'newrelic_rpm',                             '~> 3.18.1'
gem 'airbrake',                                 '~> 5.7.1'

# Cache store
gem 'redis-rails',                              '~> 5.0.1'
gem 'redis',                                    '~> 3.3.2'
gem 'redis-namespace',                          '~> 1.5.2'

# Security
gem 'rack-attack',                              '~> 5.0.1'
gem 'easy_captcha',                             '~> 0.6.5'

# CSS / JS
gem 'sass-rails',                               '~> 5.0.6'
gem 'font-awesome-sass',                        '~> 4.7.0'
gem 'bootstrap',                                '~> 4.0.0.alpha6'
gem 'bootstrap-datepicker-rails',               '~> 1.6.4'
gem 'uglifier',                                 '~> 3.0.4'
gem 'coffee-rails',                             '~> 4.2.1'
gem 'jquery-rails',                             '~> 4.2.1'
gem 'i18n-js',                                  '~> 3.0.0'
gem 'select2-rails',                            '~> 4.0.3'
## tether positionning for popovers and tooltips
source 'https://rails-assets.org' do
  gem 'rails-assets-tether',                    '~> 1.4.0'
end

# User account
gem 'devise',                                   '~> 4.2.0'
gem 'devise_security_extension',                '~> 0.9.2'
gem 'rolify',                                   '~> 5.1.0'

# Validators
gem 'rails_email_validator',                    '~> 0.1.4'
gem 'activevalidators',                         '~> 4.0.1'
gem 'iban-tools',                               '~> 1.1.0'

# Relation
gem 'ancestry',                                 '~> 2.2.2'

# Images / PDF
gem 'rmagick',                                  '~> 2.16.0'
gem 'prawn',                                    '~> 2.2.2'

# Views helpers
gem 'simple_form',                              '~> 3.3.1'
gem 'awesome_print',                            '~> 1.7.0'

# Encryption
gem 'jwt',                                      '~> 1.5.6'

# Third-party
gem 'aws-sdk-rails',                            '~> 1.0.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug',                                 '~> 9.0.6', platform: :mri

  # Environment variables
  gem 'dotenv-rails',                           '~> 2.1.1'

  # Tests
  gem 'rspec-rails',                            '~> 3.5.2'
  gem 'capybara',                               '~> 2.11.0'
  gem 'capybara-webkit',                        '~> 1.1.0'
  gem 'capybara-screenshot',                    '~> 1.0.14'
  gem 'selenium-webdriver',                     '~> 3.0.5'
  gem 'webmock',                                '~> 3.0.1'
  gem 'pry-rails',                              '~> 0.3.4'
  gem 'pry-byebug',                             '~> 3.4.2'
  gem 'factory_girl_rails',                     '~> 4.7.0'
  gem 'database_cleaner',                       '~> 1.5.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console',                            '~> 3.4.0'
  gem 'listen',                                 '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring',                                 '~> 2.0.0'
  gem 'spring-watcher-listen',                  '~> 2.0.1'

  # Intercept mail
  gem 'letter_opener',                          '~> 1.4.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
