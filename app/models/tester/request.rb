module Tester
  class Request < ApplicationRecord

    belongs_to :route
    belongs_to :user

    validates :user, presence: true
    validates :method, inclusion: {in: Route::ALLOWED_METHODS}
    validates :format, inclusion: {in: Route::ALLOWED_FORMATS}

    validate :body_format_validation

    # STI
    def self.inherited(subclass)
      super
      def subclass.model_name
        superclass.model_name
      end
    end

    private

      def body_format_validation
        case format
          when 'application/json'
            begin
              JSON.parse(body)
            rescue JSON::ParserError
              errors.add(:body, I18n.t('errors.messages.invalid_json'))
            end
        end
      end

  end
end