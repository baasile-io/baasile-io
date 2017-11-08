module TesterResultsHelper

  def format_error_message(error_message)
    "<table class=\"table table-condensed\"><tbody><tr><td>
      #{error_message
               .gsub(/\*(.*?)\*/) {|match| "<strong>#{$1}</strong>"}
               .gsub(/`(.*?)`/) {|match| "<span class=\"badge badge-warning\">#{$1}</span>"}
               .split('; ')
               .join('</td></tr><tr><td>')}
    </td></tr></tbody></table>".html_safe
  end

end