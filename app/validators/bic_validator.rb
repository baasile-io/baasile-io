class BicValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([a-zA-Z]{4}[a-zA-Z]{2}[a-zA-Z0-9]{2}([a-zA-Z0-9]{3})?)\z/
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.not_a_bic'))
    end
  end
end