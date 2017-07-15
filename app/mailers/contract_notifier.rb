class ContractNotifier < ApplicationMailer

  def send_validated_status_notification(contract, user, from_status:)
    @contract = contract
    @user_locale = user.try(:language) || I18n.default_locale
    I18n.with_locale(@user_locale) do
      @staging_name = I18n.t("types.contract_statuses.#{contract.status}.title")
      mail( to: user.email,
            subject: I18n.t("mailer.contract_notifier.send_validated_status_notification.subject", status: @staging_name) )
    end
  end

  def send_rejected_status_notification(contract, user, from_status:)
    @contract = contract
    @user_locale = user.try(:language) || I18n.default_locale
    I18n.with_locale(@user_locale) do
      @staging_name = I18n.t("types.contract_statuses.#{contract.status}.title")
      mail( to: user.email,
            subject: I18n.t("mailer.contract_notifier.send_rejected_status_notification.subject", status: @staging_name) )
    end
  end

end
