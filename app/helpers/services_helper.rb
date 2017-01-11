module ServicesHelper
  def is_admin_of(service)
    return @service.has_role? :all, service
  end
end
