module Tester
  class Request < ApplicationRecord

    # Versioning
    has_paper_trail

    belongs_to :route
    belongs_to :user
    belongs_to :category

    has_many :tester_parameters,
             inverse_of: :tester_request,
             class_name: Tester::Parameter.name,
             foreign_key: 'tester_request_id',
             dependent: :destroy

    has_many :tester_parameters_headers,
             inverse_of: :tester_request,
             class_name: Tester::Parameters::Header.name,
             foreign_key: 'tester_request_id',
             dependent: :destroy

    has_many :tester_parameters_queries,
             inverse_of: :tester_request,
             class_name: Tester::Parameters::Query.name,
             foreign_key: 'tester_request_id',
             dependent: :destroy

    has_many :tester_results,
             inverse_of: :tester_request,
             class_name: Tester::Result.name,
             foreign_key: 'tester_request_id',
             dependent: :destroy

    validates :user, presence: true
    validates :method, inclusion: {in: Route::ALLOWED_METHODS}
    validates :format, inclusion: {in: Route::ALLOWED_FORMATS}

    validate :body_format_validation

    accepts_nested_attributes_for :tester_parameters_headers,
                                  allow_destroy: true

    accepts_nested_attributes_for :tester_parameters_queries,
                                  allow_destroy: true

    scope :standards, -> { where.not(type: Tester::Requests::Template.name)}
    scope :templates, -> { where(type: Tester::Requests::Template.name)}

    # STI
    def self.inherited(subclass)
      super
      def subclass.model_name
        superclass.model_name
      end
    end

    def template?
      type == Tester::Requests::Template.name
    end

    def standard?
      !template?
    end

    def dup_with_associations
      self.dup.tap do |new_request|
        I18n.available_locales.each do |locale|
          new_request.send("dictionary_#{locale}=", self.send("dictionary_#{locale}").dup)
        end
        self.tester_parameters_headers.each do |tester_parameter|
          new_request.tester_parameters_headers << tester_parameter.dup
        end
        self.tester_parameters_queries.each do |tester_parameter|
          new_request.tester_parameters_queries << tester_parameter.dup
        end
        self.tester_parameters_response_headers.each do |tester_parameter|
          new_request.tester_parameters_response_headers << tester_parameter.dup
        end
        self.tester_parameters_response_body_elements.each do |tester_parameter|
          new_request.tester_parameters_response_body_elements << tester_parameter.dup
        end
      end
    end

    private

      def body_format_validation
        if Route::ALLOWED_METHODS.include?(self.method) && self.request_body.present?
          begin
            JSON.parse(request_body)
          rescue JSON::ParserError
            errors.add(:body, I18n.t('errors.messages.invalid_json'))
          end
        end
      end

  end
end