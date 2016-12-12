class ActivateServiceJob < ApplicationJob
  rescue_from PG::DuplicateSchema do |exception|
    confirm_service
  end

  def perform(service_id)
    @service_id = service_id
    Apartment::Tenant.create(service_id.to_s)
    confirm_service
  end

  def confirm_service
    Service.transaction do
      s = Service.find(@service_id)
      s.confirmed_at = Date.new if s.confirmed_at.nil?
      s.generate_client_id!
      s.generate_client_secret!
      s.save!
    end
  end
end
