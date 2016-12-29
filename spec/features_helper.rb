require 'rails_helper'
require 'capybara/rspec'

RSpec.configure do |config|
  config.include Capybara::DSL

  Capybara.default_max_wait_time = 5
  Capybara.app_host = 'http://baasile-io-demo.dev:3042'
  Capybara.server_port = 3042
  Capybara.javascript_driver = :webkit
  Capybara.ignore_hidden_elements = false
end
