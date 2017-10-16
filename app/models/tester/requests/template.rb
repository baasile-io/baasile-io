module Tester
  module Requests
    class Template < Request

      has_many :tester_parameters_body_elements,
               inverse_of: :tester_request,
               class_name: Tester::Parameters::BodyElement.name,
               foreign_key: 'tester_request_id',
               dependent: :destroy

      validates :name, presence: true

      accepts_nested_attributes_for :tester_parameters_body_elements,
                                    allow_destroy: true

    end
  end
end