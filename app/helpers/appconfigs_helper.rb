module AppconfigsHelper
  def convert_appconfig_value(setting_type, value)
    case setting_type
      when :boolean
        case value
          when 't', 'true', '1', true, 1 then true
          else false
        end
      when :integer
        value.to_i
      when :numeric
        value.to_f
      else
        value
    end
  end
end