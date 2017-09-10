module Tester
  class Parameter < ApplicationRecord

    belongs_to :tester_request,
               inverse_of: :tester_parameters,
               class_name: Tester::Request.name

    validates :tester_request, presence: true
    validates :name, presence: true

    default_scope { order(name: :asc) }

    # STI
    def self.inherited(subclass)
      super
      def subclass.model_name
        superclass.model_name
      end
    end

  end
end