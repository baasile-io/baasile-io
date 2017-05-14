class BankDetail < ApplicationRecord
  # Versioning
  has_paper_trail

  belongs_to    :user
  belongs_to    :service

  has_many :contracts_as_client, class_name: Contract.name, foreign_key: 'client_bank_detail_id', dependent: :restrict_with_error
  has_many :contracts_as_startup, class_name: Contract.name, foreign_key: 'startup_bank_detail_id', dependent: :restrict_with_error

  validates     :iban, iban: true, presence: true
  validates     :bic, bic: true, presence: true
  validates     :account_owner, presence: true
  validates     :bank_name, presence: true
  validates     :service, presence: true
  validates     :user, presence: true
  validates     :name, presence:true, uniqueness: {scope: [:service]}

  scope :by_service, ->(service) { where(service: service)}
  scope :activated, -> { where(is_active: true)}
end
