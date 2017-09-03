module Tests
  class Request < ApplicationRecord

    belongs_to :route
    belongs_to :user

    validates :method, inclusion: {in: Route::ALLOWED_METHODS}
    validates :format, inclusion: {in: Route::ALLOWED_FORMATS}

  end
end