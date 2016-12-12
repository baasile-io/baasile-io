class ApplicationJob < ActiveJob::Base
  queue_as :default

  after_enqueue do |job|
    #add to TaskList
  end

  after_perform do |job|
    #remove from TaskList
  end
end
