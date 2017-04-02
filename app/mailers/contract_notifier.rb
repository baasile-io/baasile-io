class ContractNotifier < ApplicationMailer

  def send_by_status(contract, staging, staging_name)
    @contract = contract
    @staging_name = staging_name
    @service = contract.send(staging[:can_edit])
    scope_val = "main_#{staging[:scope]}"
    user_by_scope = @service.send(scope_val.to_sym)
    unless user_by_scope.nil?
      mail( :to => user_by_scope.email,
          :subject => I18n.t("mailer.contract_notifier.send_by_status.#{@staging_name}.subject") )
    end
    unless @service.user.nil?
      mail( :to => @service.user.email,
          :subject => I18n.t("mailer.contract_notifier.send_by_status.#{@staging_name}.subject") )
    end
  end

end
