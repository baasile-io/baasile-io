class AmountInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    default_extra_class = input_html_options.fetch(:extra_class)
    input_html_classes << "autonumeric_amount "
    input_html_classes << "#{default_extra_class} "
    input_html_options[:type] = "text"

    super
  end
end