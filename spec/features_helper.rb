require 'rails_helper'
require 'capybara/rspec'
require 'capybara/webkit'

Capybara.default_max_wait_time = 5
Capybara.app_host = 'http://baasile-io-demo.dev:3042'
Capybara.server_port = 3042
Capybara.javascript_driver = :webkit
Capybara.ignore_hidden_elements = false

if ENV['SELENIUM_REMOTE_HOST']
  Capybara.javascript_driver = :selenium_remote_firefox
  Capybara.register_driver "selenium_remote_firefox".to_sym do |app|
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://#{ENV['SELENIUM_REMOTE_HOST']}:4444/wd/hub",
      desired_capabilities: :firefox
    )
  end
end

RSpec.configure do |config|
  config.include Capybara::DSL

  #config.before(:each) do
  #  if /selenium_remote/.match Capybara.current_driver.to_s
  #    ip = `/sbin/ip route|awk '/scope/ { print $9 }'`
  #    ip = ip.gsub "\n", ""
  #    Capybara.server_port = "3042"
  #    Capybara.server_host = ip
  #    Capybara.app_host = "http://#{Capybara.current_session.server.host}:#{Capybara.current_session.server.port}"
  #  end
  #end
end
