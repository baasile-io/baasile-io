module Tester
  module Requests
    class Standard < Request

      has_one :proxy, through: :route
      has_one :service, through: :route

      validate :body_format_validation

      private

        def body_format_validation
          case format
            when 'application/json'
              begin
                JSON.parse(body)
              rescue JSON::ParserError
                errors.add(:body, 'invalid')
              end
          end
        end

    end
  end
end