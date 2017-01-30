class ContactDetail < ApplicationRecord
  belongs_to :contactable, polymorphic: true
end
