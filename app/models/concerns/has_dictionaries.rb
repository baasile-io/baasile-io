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
    self.send("dictionary_#{I18n.locale}").title
  end

  def body
    self.send("dictionary_#{I18n.locale}").body
  end

  def last_modified
    self.send("dictionary_#{I18n.locale}").updated_at
  end

  def validate_dictionary_attributes
    I18n.available_locales.each do |locale|
      self.class.mandatory_dictionary_attributes.each do |attr|
        if self.send("dictionary_#{locale}").send(attr).blank?
          self.send("dictionary_#{locale}").errors.add(attr, I18n.t('errors.messages.missing_translation'))
        end
      end
      if self.send("dictionary_#{locale}").errors.any?
        self.errors.add(:base, I18n.t('errors.messages.missing_translation_for_locale', current_locale: I18n.t("misc.locales.#{locale}")))
      end
    end
  end
end