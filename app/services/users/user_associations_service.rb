module Users
  class UserAssociationsService
    class UnknownUserRole < StandardError; end
    class UnableToAddRoleToUser < StandardError; end

    def initialize(user)
      @user = user
    end

    def create_association(service, role = nil)
      begin
        UserAssociation.transaction do
          raise UnknownUserRole if role && !Role::USER_ROLES.include?(role)
          UserAssociation.create!(user: @user, associable: service) unless UserAssociation.exists?(user: @user, associable: service)
          raise UnableToAddRoleToUser if role && !@user.add_role(role, service)
        end
      rescue
        return false
      end
      true
    end
  end
end