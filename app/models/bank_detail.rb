class BankDetail < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to    :user
  belongs_to    :contract
  belongs_to    :service

  validates     :iban, iban: true, presence: true
  validates     :bic, bic: true, presence: true
  validates     :account_owner, presence: true
  validates     :bank_name, presence: true
  validates     :service, presence: true
  validates     :user, presence: true
  validates     :name, presence:true, uniqueness: {scope: [:service, :contract]}


  scope :by_service, ->(service) { where(service: service)}
  scope :templates, -> { where(contract: nil)}
  scope :activated, -> { where(is_active: true)}

end
