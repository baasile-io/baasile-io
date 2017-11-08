module Api
  module Tester
    class RequestTemplateParser

      def initialize(request_template:, result:)
        @request_template = request_template
        @result = result
        @errors = []
        @body = nil

        unless @result[:response].present?
          @result[:response] = {
            status: @result[:status],
            headers: {},
            body: case request_template.expected_response_format
                    when 'application/json'
                      {}
                    else
                      raise StandardError
                  end
          }
        end
      end

      def call
        parse_result
      end

      private

      attr_reader :request_template, :result, :errors, :body
      attr_writer :body

      def parse_result
        check_status
        check_headers
        if check_format
          check_body
        end
        #else
        #  push_error "*#{result[:error_title]}*: #{result[:error_message]}"
        #end

        [errors.empty?, errors]
      end

      def check_format
        return true if @result[:error]

        @body = case request_template.expected_response_format
                  when 'application/json'
                    JSON.parse(result[:response][:body])
                  else
                    raise StandardError
                end

        true
      rescue
        push_error I18n.t("tester.parser.messages.bad_format",
                          expected_response_format: request_template.expected_response_format)

        false
      end

      def check_status
        return unless request_template.expected_response_status.present?

        if request_template.expected_response_status != result[:status]
          push_error I18n.t("tester.parser.messages.bad_status",
                            expected_response_status: request_template.expected_response_status)
        end
      end

      def check_headers
        request_template.tester_parameters_response_headers.each do |header_parameter|
          compare_parameter(
            parameter: header_parameter,
            path: Rack::Utils.parse_nested_query(header_parameter.name),
            container: result[:response][:headers],
            container_id: :headers
          )
        end
      end

      def check_body
        request_template.tester_parameters_response_body_elements.each do |body_parameter|
          compare_parameter(
            parameter: body_parameter,
            path: Rack::Utils.parse_nested_query(body_parameter.name),
            container: body,
            container_id: :body_elements
          )
        end
      end

      def compare_parameter(parameter:, path:, container:, container_id:)
        key, new_path = path&.first

        if new_path.is_a?(Hash) && container.is_a?(Hash)
          compare_parameter(parameter: parameter, path: new_path, container: container[key], container_id: container_id)
        elsif new_path.is_a?(Array)
          if new_path.empty?
            compare_parameter(parameter: parameter, path: nil, container: container, container_id: container_id)
          else
            if container.is_a?(Array)
              container[key].each do |sub_container|
                compare_parameter(parameter: parameter, path: new_path.first, container: sub_container, container_id: container_id)
              end
            else
              compare_parameter(parameter: parameter, path: nil, container: nil, container_id: container_id)
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
                       value.present? && value.is_a?(String) && value.match(/\A#{parameter.value}\z/)
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
            push_error I18n.t("tester.parser.messages.comparison_operators.#{parameter.comparison_operator}",
                              container: I18n.t("misc.response_#{container_id}"),
                              attribute: parameter.name,
                              value: parameter.value,
                              expected_type: I18n.t("types.expected_types.#{parameter.expected_type}"))
          end
        end
      end

      def push_error(message)
        errors << message
      end

    end
  end
end