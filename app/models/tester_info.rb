class TesterInfo < ApplicationRecord
  # Versioning
  has_paper_trail

  REQ_REST_TYPES = {post: 1, get: 2, put: 3, patch: 4, del: 5}
  enum req_type: REQ_REST_TYPES

  belongs_to :proxy
  belongs_to :service
  belongs_to :user

end
