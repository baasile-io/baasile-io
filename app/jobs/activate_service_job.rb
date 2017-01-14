class ActivateServiceJob < ApplicationJob
=begin
  rescue_from PG::DuplicateSchema do |exception|
    confirm_service
  end

  rescue_from Apartment::TenantExists do |exception|
    confirm_service
  end
=end

  def perform(service_id)
    @service = Service.find(service_id)
    if @service.is_activable?
      #Apartment::Tenant.create(@service.subdomain)
      confirm_service
    end
  end

  def confirm_service
    Service.transaction do
      @service.confirmed_at = Date.new if @service.confirmed_at.nil?
      @service.generate_client_id!
      @service.generate_client_secret!
      @service.save!
      ServiceNotifier.send_validation(@service).deliver_now
    end
  end
end
