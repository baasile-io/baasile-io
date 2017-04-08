class Category < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries

  belongs_to :user
  has_many :proxies, dependent: :nullify

  def name
    self.title
  end

  def description
    self.body
  end
end
