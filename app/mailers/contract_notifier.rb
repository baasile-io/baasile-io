class ContractNotifier < ApplicationMailer

  def send_by_status(contract, staging, staging_name)
    @contract = contract
    @staging_name = staging_name
    @service = contract.send(staging[:can_edit])
    users = @service.user_by_scope(staging[:scope])
    users.each do |u|
      mail( :to => u.email,
            :subject => I18n.t("mailer.contract_notifier.send_by_status.#{@staging_name}.subject") )
    end
  end
end
