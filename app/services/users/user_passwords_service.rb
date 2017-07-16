module Users
  class UserPasswordsService
    def initialize(user)
      @user = user
    end

    def assign_random_password(expired: true)
      @user.password_confirmation = @user.password = random_password
      @user.password_changed_at = 1.year.ago if expired
    end

    def reset_password
      begin
        User.transaction do
          assign_random_password
          @user.save!
          UserNotifier.send_reset_password(@user, @user.password).deliver_now
        end
        true
      rescue
        false
      end
    end

    private

    def random_password
      (('a'..'k').to_a + ('L'..'Z').to_a + ('0'..'9').to_a + ['/', '.', '?', '%']).shuffle.join
    end
  end
end