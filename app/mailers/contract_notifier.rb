class ContractNotifier < ApplicationMailer

  def send_validated_status_notification(contract, from_status:)
    @contract = contract

    users_to_be_notified(contract, from_status).each do |user|
      locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(locale) do
        @staging_name = I18n.t("types.contract_statuses.#{contract.status}.title")
        mail( to: user.email,
              subject: I18n.t("mailer.contract_notifier.send_validated_status_notification.subject", status: @staging_name) )
      end
    end
  end

  def send_rejected_status_notification(contract, from_status:)
    @contract = contract

    users_to_be_notified(contract, from_status).each do |user|
      @user_locale = user.try(:language) || I18n.default_locale
      I18n.with_locale(@user_locale) do
        @staging_name = I18n.t("types.contract_statuses.#{contract.status}.title")
        mail( to: user.email,
              subject: I18n.t("mailer.contract_notifier.send_rejected_status_notification.subject", status: @staging_name) )
      end
    end
  end

  private

  def users_to_be_notified(contract, status)
    Contract::CONTRACT_STATUSES[status][:notifications].each_with_object([]) do |(service_type, user_roles), users|
      user_roles.each do |user_role|
        users << contract.send(service_type).send("main_#{user_role}")
      end
    end.reject(&:blank?).uniq
  end

end
