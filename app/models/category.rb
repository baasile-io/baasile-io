class Category < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries
  has_mandatory_dictionary_attributes :title

  belongs_to :user
  has_many :proxies, dependent: :nullify

  def name
    title
  end

  def description
    body
  end
end
