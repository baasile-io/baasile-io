class ApplicationMailer < ActionMailer::Base
  default from: ENV['BAASILE_IO_CONTACT']
  layout 'mailer'
end
