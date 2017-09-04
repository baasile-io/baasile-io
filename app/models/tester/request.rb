module Tester
  class Request < ApplicationRecord

    belongs_to :route
    belongs_to :user

    has_one :proxy, through: :route
    has_one :service, through: :route

    validates :method, inclusion: {in: Route::ALLOWED_METHODS}
    validates :format, inclusion: {in: Route::ALLOWED_FORMATS}

  end
end