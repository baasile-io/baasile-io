class Documentation < ApplicationRecord
  # Versioning
  has_paper_trail

  DOCUMENTATION_TYPES = {section: {index: 1}, article: {index: 2}, category: {index: 3}}
  DOCUMENTATION_TYPES_ENUM = DOCUMENTATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum documentation_type: DOCUMENTATION_TYPES_ENUM

  has_ancestry orphan_strategy: :adopt
  has_many :dictionaries, as: :localizable

  I18n.available_locales.each do |locale|
    has_one "dictionary_#{locale}".to_sym, -> {where(locale: locale)}, class_name: Dictionary.name, as: :localizable, inverse_of: 'localizable'
    accepts_nested_attributes_for "dictionary_#{locale}".to_sym, allow_destroy: true
    validates "dictionary_#{locale}".to_sym, presence: true
  end

  scope :roots,     -> { where(ancestry: nil) }
  scope :published, -> { where(public: true) }

  def name
    self.title
  end

  def title
    self.send("dictionary_#{I18n.locale}").title
  end

  def body
    self.send("dictionary_#{I18n.locale}").body
  end
end
