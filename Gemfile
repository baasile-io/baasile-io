source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Databases
gem 'pg', '~>0.19'

# Cache store
gem 'redis-rails'
gem 'redis'
gem 'redis-namespace'

# User account
gem 'devise', '~>4.2'
gem 'rolify', '~>5.1.0'
gem 'devise_security_extension'
gem 'rails_email_validator'
gem 'easy_captcha'
#gem 'apartment', '~>1.2'

# Security
gem 'rack-attack'

# Front
gem 'bootstrap', '~> 4.0.0.alpha5'
gem 'font-awesome-sass'
gem 'simple_form', '~>3.3.1'
## tether positionning for popovers and tooltips
source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

# Background jobs
#gem 'apartment-sidekiq'
gem 'sidekiq'

# API authentication
gem 'jwt'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  # Environment variables
  gem 'dotenv-rails'

  # Tests
  gem 'rspec-rails', '~> 3.5'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'selenium-webdriver'
  gem 'capybara-screenshot'
  gem 'pry-rails'
  gem 'factory_girl_rails'
  gem 'database_cleaner'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Intercept mail
  gem 'letter_opener'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
