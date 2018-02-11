# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: (ENV['BAASILE_IO_HOSTNAME'] || '_baasile-io_session'), domain: (Rails.env.test? || Rails.env.development? ? :all : ".#{ENV['BAASILE_IO_HOSTNAME']}")
