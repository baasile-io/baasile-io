module Tester
  module Requests
    class Template < Request

      include HasDictionaries
      has_mandatory_dictionary_attributes :title, :body
      after_initialize :build_dictionaries

      has_many :tester_parameters_response_headers,
               inverse_of: :tester_request,
               class_name: Tester::Parameters::ResponseHeader.name,
               foreign_key: 'tester_request_id',
               dependent: :destroy

      has_many :tester_parameters_response_body_elements,
               inverse_of: :tester_request,
               class_name: Tester::Parameters::ResponseBodyElement.name,
               foreign_key: 'tester_request_id',
               dependent: :destroy

      validates :expected_response_status, presence: true

      accepts_nested_attributes_for :tester_parameters_response_headers,
                                    allow_destroy: true

      accepts_nested_attributes_for :tester_parameters_response_body_elements,
                                    allow_destroy: true

      def template_name
        title
      end

      def template_description
        body
      end

      private

      def build_dictionaries
        I18n.available_locales.each do |locale|
          self.send("build_dictionary_#{locale}") unless self.send("dictionary_#{locale}")
        end
      end

    end
  end
end