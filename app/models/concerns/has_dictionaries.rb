module HasDictionaries
  extend ActiveSupport::Concern

  included do
    has_many :dictionaries, as: :localizable

    I18n.available_locales.each do |locale|
      has_one "dictionary_#{locale}".to_sym, -> {where(locale: locale)}, class_name: Dictionary.name, as: :localizable, inverse_of: 'localizable'
      accepts_nested_attributes_for "dictionary_#{locale}".to_sym, allow_destroy: true
      validates "dictionary_#{locale}".to_sym, presence: true
    end

    validate :validate_dictionary_attributes
  end

  module ClassMethods
    def has_mandatory_dictionary_attributes(*attributes)
      attributes.each do |attr|
        mandatory_dictionary_attributes << attr
      end
    end

    def mandatory_dictionary_attributes
      @mandatory_dictionary_attributes ||= []
    end
  end

  def title
    get_dictionnary_attr(:title)
  end

  def body
    get_dictionnary_attr(:body)
  end

  def last_modified
    get_dictionnary_attr(:updated_at)
  end

  private

  def get_dictionnary_attr(attribute_name)
    return send("dictionary_#{I18n.locale}").send(attribute_name) if send("dictionary_#{I18n.locale}").send(attribute_name).present?
    fallback_attribute_translation(attribute_name)
  end

  def fallback_attribute_translation(attribute_name)
    I18n.available_locales.each do |locale|
      return send("dictionary_#{locale}").send(attribute_name) if send("dictionary_#{locale}").send(attribute_name).present?
    end
    ''
  end

  def validate_dictionary_attributes
    I18n.available_locales.each do |locale|
      self.class.mandatory_dictionary_attributes.each do |attr|
        if send("dictionary_#{locale}").send(attr).blank?
          send("dictionary_#{locale}").errors.add(attr, I18n.t('errors.messages.missing_translation'))
        end
      end
      if send("dictionary_#{locale}").errors.any?
        errors.add(:base, I18n.t('errors.messages.missing_translation_for_locale', current_locale: I18n.t("misc.locales.#{locale}")))
      end
    end
  end
end