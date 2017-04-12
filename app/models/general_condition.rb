class GeneralCondition < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries

  belongs_to :user

  def name
    self.title
  end

end
