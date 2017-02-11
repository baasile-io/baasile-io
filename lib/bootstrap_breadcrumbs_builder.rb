# https://gist.github.com/riyad/1933884

class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @context.content_tag(:nav, class: 'breadcrumb') do
      @elements.collect do |element|
        render_element(element)
      end.join.html_safe
    end
  end

  def render_element(element)
    current = @context.current_page?(compute_path(element))

    @context.content_tag(:a, :class => ("breadcrumb-item #{'active' if current}")) do
      link_or_text = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
    end
  end
end