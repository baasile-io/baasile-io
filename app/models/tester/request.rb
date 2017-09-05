module Tester
  class Request < ApplicationRecord

    belongs_to :route
    belongs_to :user

    validates :user, presence: true
    validates :method, inclusion: {in: Route::ALLOWED_METHODS}
    validates :format, inclusion: {in: Route::ALLOWED_FORMATS}

    # STI
    def self.inherited(subclass)
      super
      def subclass.model_name
        superclass.model_name
      end
    end

  end
end