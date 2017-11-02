module Tester
  module Requests
    class Template < Request

      EXPECTED_RESPONSE_FORMATS = %w(application/json)

      include HasDictionaries
      has_mandatory_dictionary_attributes :title, :body

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

      has_many :tester_results

      validates :expected_response_status, numericality: { only_integer: true }, allow_blank: true
      validates :expected_response_format, presence: true, inclusion: {in: EXPECTED_RESPONSE_FORMATS}

      accepts_nested_attributes_for :tester_parameters_response_headers,
                                    allow_destroy: true

      accepts_nested_attributes_for :tester_parameters_response_body_elements,
                                    allow_destroy: true

      before_save :initialize_expiration_date

      scope :by_category, -> (category_id) {
        where('tester_requests.category_id IS NULL OR tester_requests.category_id = ?', category_id)
      }

      scope :applicable_on_route, -> (route) {
        by_category(route.proxy.category_id)
      }

      scope :with_missing_results, -> {
        joins('LEFT JOIN tester_results ON tester_results.tester_request_id = tester_requests.id AND tester_results.updated_at >= tester_requests.expiration_date')
          .where("tester_results.id IS NULL")
      }

      scope :with_failed_results, -> {
        joins('LEFT JOIN tester_results ON tester_results.tester_request_id = tester_requests.id AND tester_results.updated_at >= tester_requests.expiration_date')
          .where("tester_results.status = 'f'")
      }

      scope :with_failed_or_missing_results, -> {
        with_missing_results.or(with_failed_results)
      }

      def template_name
        title
      end

      def template_description
        body
      end

      def update_expiration_date
        self.expiration_date = DateTime.now
      end

      private

      def initialize_expiration_date
        update_expiration_date if self.expiration_date.nil?
      end

    end
  end
end