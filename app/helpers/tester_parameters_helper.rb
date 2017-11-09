module TesterParametersHelper
  def format_tester_parameter_comparison_operators_for_select
    Tester::Parameter::COMPARISON_OPERATORS.map do |comparison_operator, options|
      [
        I18n.t("types.comparison_operators.#{comparison_operator}"),
        comparison_operator,
        'data-has-value': options[:has_value],
        'data-has-expected-type': options[:has_expected_type]
      ]
    end
  end

  def format_tester_parameter_expected_types_for_select
    Tester::Parameter::EXPECTED_TYPES.map do |expected_type|
      [
        I18n.t("types.expected_types.#{expected_type}"),
        expected_type
      ]
    end
  end
end