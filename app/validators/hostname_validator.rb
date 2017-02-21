class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/i
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.not_a_hostname'))
    end
  end
end