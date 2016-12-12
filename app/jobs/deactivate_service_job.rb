class DeactivateServiceJob < ApplicationJob
  def perform(service_id)
    s = Service.find(service_id)
    s.confirmed_at = nil
    s.save
  end
end
