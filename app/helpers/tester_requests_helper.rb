module TesterRequestsHelper

  def build_headers(tester_parameters)
    {}.tap do |parameters|
      tester_parameters.each do |header_parameter|
        parameters[header_parameter.name.upcase.gsub(/_/, '-')] = header_parameter.value
      end
    end
  end
end