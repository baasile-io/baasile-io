module Tester
  class Parameter < ApplicationRecord

    COMPARISON_OPERATORS = {
      '=':        {has_value: true,  has_expected_type: false},
      '!=':       {has_value: true,  has_expected_type: false},
      '>':        {has_value: true,  has_expected_type: false},
      '>=':       {has_value: true,  has_expected_type: false},
      '<':        {has_value: true,  has_expected_type: false},
      '<=':       {has_value: true,  has_expected_type: false},
      '&':        {has_value: true,  has_expected_type: false},
      'present':  {has_value: false, has_expected_type: false},
      'any':      {has_value: false, has_expected_type: false},
      'null':     {has_value: false, has_expected_type: false},
      'typeof':   {has_value: false, has_expected_type: true}
    }.freeze

    EXPECTED_TYPES = [
      'string',
      'integer',
      'hash',
      'array'
    ].freeze

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