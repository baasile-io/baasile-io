class Documentation < ApplicationRecord
  # Versioning
  has_paper_trail

  DOCUMENTATION_TYPES = {root: {index: 1}}
  DOCUMENTATION_TYPES_ENUM = DOCUMENTATION_TYPES.each_with_object({}) do |k, h| h[k[0]] = k[1][:index] end
  enum documentation_type: DOCUMENTATION_TYPES_ENUM

  has_ancestry orphan_strategy: :adopt

  validates :locale, presence: true
  validates :title, presence: true
  validates :body, presence: true

  scope :platform, -> { where(documentation_type: DOCUMENTATION_TYPES[:root][:index]) }
end
