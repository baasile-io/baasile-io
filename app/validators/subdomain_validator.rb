class SubdomainValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[\-A-Za-z0-9]*\z/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.not_a_subdomain'))
    end
  end
end