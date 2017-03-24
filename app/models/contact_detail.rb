class ContactDetail < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to :contactable, polymorphic: true

  validates :address_line1, presence: true
  validates :zip, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :phone, presence: true, phone: true
end
