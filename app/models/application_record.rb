class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  default_scope {order(updated_at: :desc)}
end
