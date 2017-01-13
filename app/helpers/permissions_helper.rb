module PermissionsHelper

  def type_acces_to(service_owner, target)
    if  service_owner.has_role? :all, target
      return "all"
    else
      return "no"
    end
  end

end
