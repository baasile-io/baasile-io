class HostnameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::HOST
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.not_a_hostname'))
    end
  end
end