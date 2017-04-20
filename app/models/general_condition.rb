class GeneralCondition < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries
  has_mandatory_dictionary_attributes :title, :body

  belongs_to :user

  has_many :contracts

  validates :cg_version, presence: true
  validates :effective_start_date, presence: true

  def name
    self.title
  end

  def is_used?
    return self.contracts && self.contracts.count > 0
  end

end
