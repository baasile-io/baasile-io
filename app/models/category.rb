class Category < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries
  has_mandatory_dictionary_attributes :title

  belongs_to :user
  has_many :proxies, dependent: :nullify
  has_many :tester_requests, dependent: :destroy, class_name: Tester::Request.name

  def name
    title
  end

  def description
    body
  end

  def to_s
    name
  end
end
