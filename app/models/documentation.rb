class Documentation < ApplicationRecord
  # Versioning
  has_paper_trail

  include HasDictionaries

  DOCUMENTATION_TYPES = {section: {index: 1}, article: {index: 2}, category: {index: 3}}
  DOCUMENTATION_TYPES_ENUM = DOCUMENTATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum documentation_type: DOCUMENTATION_TYPES_ENUM

  has_ancestry orphan_strategy: :adopt

  scope :roots,     -> { where(ancestry: nil) }
  scope :published, -> { where(public: true) }

  def name
    self.title
  end
end
