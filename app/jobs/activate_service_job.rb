class ActivateServiceJob < ApplicationJob
  queue_as :default

  rescue_from PG::DuplicateSchema do |exception|
    confirm_service
  end

  def perform(service_id)
    @service_id = service_id
    Apartment::Tenant.create(service_id.to_s)
    confirm_service
  end

  def confirm_service
    s = Service.find(@service_id)
    s.confirmed_at = Date.new if s.confirmed_at.nil?
    s.save
  end
end
