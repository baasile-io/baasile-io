class IbanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    unless IBANTools::IBAN.valid? values
      record.errors.add attribute, (options[:message] || I18n.t('errors.messages.not_an_iban'))
    end
  end
end