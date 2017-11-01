module Api
  module Tester
    class RequestTemplateParser

      def initialize(request_template:, response:)
        @request_template = request_template
        @response = response
        @errors = []
        @body = nil
      end

      def call
        parse_result
      end

      private

      attr_reader :request_template, :response, :errors, :body
      attr_writer :body

      def parse_result
        if response.present?
          check_status
          check_headers
          if check_format
            check_body
          end
        else
          push_error('error')
        end

        [errors.empty?, errors]
      end

      def check_format
        @body = case request_template.expected_response_format
                  when 'application/json'
                    JSON.parse(response[:body])
                  else
                    raise StandardError
                end

        true
      rescue
        push_error('bad format')

        false
      end

      def check_status
        return unless request_template.expected_response_status.present?

        if request_template.expected_response_status != response[:status]
          push_error('bad status')
        end
      end

      def check_headers
        request_template.tester_parameters_response_headers.each do |header_parameter|
          compare_parameter(
            parameter: header_parameter,
            path: Rack::Utils.parse_nested_query(header_parameter.name),
            container: response[:headers]
          )
        end
      end

      def check_body
        request_template.tester_parameters_response_body_elements.each do |body_parameter|
          compare_parameter(
            parameter: body_parameter,
            path: Rack::Utils.parse_nested_query(body_parameter.name),
            container: body
          )
        end
      end

      def compare_parameter(parameter:, path:, container:)
        key, new_path = path&.first

        #if new_path.is_a?(Array) && new_path.any?
        #  raise key.inspect
        #end

        if new_path.is_a?(Hash) && container.is_a?(Hash)
          compare_parameter(parameter: parameter, path: new_path, container: container[key])
        elsif new_path.is_a?(Array)
          if new_path.empty?
            compare_parameter(parameter: parameter, path: nil, container: container)
          else
            container[key].each do |sub_container|
              compare_parameter(parameter: parameter, path: new_path.first, container: sub_container)
            end
          end
        else
          value = if key.nil?
                    container
                  elsif !container.is_a?(Hash)
                    nil
                  else
                    container[key]
                  end

          result = case parameter.comparison_operator
                     when 'present'
                       value.present?
                     when 'any'
                       value.nil?
                     when 'null'
                       !value.present?
                     when '='
                       value.to_s == parameter.value
                     when '!='
                       value.to_s != parameter.value
                     when '>'
                       value.is_a?(Numeric) && value > parameter.value.to_f
                     when '>='
                       value.is_a?(Numeric) && value >= parameter.value.to_f
                     when '<'
                       value.is_a?(Numeric) && value < parameter.value.to_f
                     when '<='
                       value.is_a?(Numeric) && value <= parameter.value.to_f
                     when '&'
                       value.present? && value.is_a?(String) && value.match(/#{parameter.value}/)
                     when 'typeof'
                       case parameter.expected_type
                         when 'string'
                           value.is_a?(String)
                         when 'integer'
                           value.is_a?(Integer)
                         when 'numeric'
                           value.is_a?(Numeric)
                         when 'hash'
                           value.is_a?(Hash)
                         when 'array'
                           value.is_a?(Array)
                         else
                           raise StandardError
                       end
                     else
                       raise StandardError
                   end

          unless result
            errors << "#{parameter.name} #{parameter.comparison_operator} #{parameter.value} #{parameter.expected_type}"
          end
        end
      end

      def push_error(message)
        errors << message
      end

    end
  end
end