module TesterResultsHelper

  def format_error_message(error_message)
    "<ul><li>
      #{error_message
               .gsub(/\*(.*?)\*/) {|match| "<strong>#{$1}</strong>"}
               .gsub(/`(.*?)`/) {|match| "<span class=\"badge badge-warning\">#{$1}</span>"}
               .split('; ')
               .join('</li><li>')}
    </li></ul>".html_safe
  end

end