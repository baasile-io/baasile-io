module HasDictionaries
  extend ActiveSupport::Concern

  included do
    has_many :dictionaries, as: :localizable

    I18n.available_locales.each do |locale|
      has_one "dictionary_#{locale}".to_sym, -> {where(locale: locale)}, class_name: Dictionary.name, as: :localizable, inverse_of: 'localizable'
      accepts_nested_attributes_for "dictionary_#{locale}".to_sym, allow_destroy: true
      validates "dictionary_#{locale}".to_sym, presence: true
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
end