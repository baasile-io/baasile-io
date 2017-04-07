class Documentation < ApplicationRecord
  # Versioning
  has_paper_trail

  DOCUMENTATION_TYPES = {root: {index: 1}, category: {index: 2}, page: {index: 3}}
  DOCUMENTATION_TYPES_ENUM = DOCUMENTATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum documentation_type: DOCUMENTATION_TYPES_ENUM

  has_ancestry orphan_strategy: :adopt
  has_many :dictionaries, as: :localizable

  I18n.available_locales.each do |locale|
    has_one "dictionary_#{locale}".to_sym, -> {where(locale: locale)}, class_name: Dictionary.name, as: :localizable, inverse_of: 'localizable'
    accepts_nested_attributes_for "dictionary_#{locale}".to_sym, allow_destroy: true
  end

  validates :locale, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :platform, -> {all}
end
