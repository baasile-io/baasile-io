module ServicesHelper

  def type_acces_to(service_owner, service_target)
    if  service_owner.has_role? :all, service_target
      return "all"
    else
      return "no"
    end
  end

end
