class Dictionary < ApplicationRecord
  # Versioning
  has_paper_trail

  include Trixable
  has_trix_attributes :body

  belongs_to :localizable, polymorphic: true

  validates :locale, presence: true, inclusion: {in: I18n.available_locales.map(&:to_s)}
end