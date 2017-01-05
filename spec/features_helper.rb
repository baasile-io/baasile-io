require 'rails_helper'
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.default_max_wait_time = 5
Capybara.app_host = 'http://baasile-io-demo.dev:3042'
Capybara.server_port = 3042
Capybara.javascript_driver = :webkit
Capybara.ignore_hidden_elements = false

if ENV['SELENIUM_REMOTE_HOST']
  Capybara.javascript_driver = :selenium_remote_firefox
  Capybara.register_driver :selenium_remote_firefox do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://#{ENV['SELENIUM_REMOTE_HOST']}:4444/wd/hub",
      desired_capabilities: :firefox
    )
  end
  Capybara.default_driver = :selenium_remote_firefox
end

RSpec.configure do |config|
  config.include Capybara::DSL

  config.use_transactional_examples = false
  config.use_transactional_fixtures = false

  config.before :each do
    if /selenium_remote/.match Capybara.current_driver.to_s
      ip = `/sbin/ip route|awk '/scope/ { print $9 }'`
      ip = ip.gsub "\n", ""
      Capybara.server_host = ip
      Capybara.app_host = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}"
    end
  end

  config.after :each do
    Capybara.reset_sessions!
  end
end
