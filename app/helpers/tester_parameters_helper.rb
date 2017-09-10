module TesterParametersHelper
  def format_tester_parameter_data_type_for_select
    Tester::Parameter::DATA_TYPES.map do |data_type|
      [
        data_type,
        data_type
      ]
    end
  end
end