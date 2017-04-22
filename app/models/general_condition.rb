class GeneralCondition < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries
  has_mandatory_dictionary_attributes :title, :body

  belongs_to :user

  has_many :contracts

  validates :gc_version, presence: true
  validates :effective_start_date, presence: true

  def name
    self.title
  end

  def is_used?
    return self.contracts && self.contracts.count > 0
  end

  def self.effective_now
    self.where('effective_start_date <= ?', Date.today).order(effective_start_date: :desc).first
  end

end
