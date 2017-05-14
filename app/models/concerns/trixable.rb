module Trixable
  extend ActiveSupport::Concern

  TRIXABLE_WHITELISTED_TAGS = %w(div blockquote h1 pre ul ol li a strong em del br)
  TRIXABLE_WHITELISTED_TAGS_RESTRICTED = %w(div blockquote h1 pre ul ol li strong em del br)
  TRIXABLE_WHITELISTED_ATTRIBUTES = %w(href)
  TRIXABLE_WHITELISTED_ATTRIBUTES_RESTRICTED = %w()
  TRIXABLE_TAGS_TO_NEWLINES_REGEX = /<(br ?\/?|\/(div|blockquote|h1|pre|li))?>/

  module ClassMethods
    def has_trix_attributes(*attributes)
      attributes.each do |attr|
        define_method "#{attr}_to_text" do
          self.class.trix_content_to_text(send(attr))
        end

        define_method "#{attr}=" do |value|
          write_attribute(attr, self.class.ensure_trix_content_consistency(false, value))
        end
      end
    end

    def has_trix_attributes_restricted(*attributes)
      attributes.each do |attr|
        define_method "#{attr}_to_text" do
          self.class.trix_content_to_text(send(attr))
        end

        define_method "#{attr}=" do |value|
          write_attribute(attr, self.class.ensure_trix_content_consistency(true, value))
        end
      end
    end

    def ensure_trix_content_consistency(restricted, html)
      html ||= ''
      doc = Nokogiri::HTML::fragment(
        ActionController::Base.helpers.sanitize(
          html,
          tags: (restricted ? TRIXABLE_WHITELISTED_TAGS_RESTRICTED : TRIXABLE_WHITELISTED_TAGS),
          attributes: (restricted ? TRIXABLE_WHITELISTED_ATTRIBUTES_RESTRICTED : TRIXABLE_WHITELISTED_ATTRIBUTES)
        )
      )
      doc.css('div, blockquote, h1, pre, ul, ol, li, a, strong, em, del').each do |p|
        p.remove if p.content.blank?
      end
      doc.css('a').each do |link|
        link['target'] = '_blank'
        # To avoid window.opener attack when target blank is used
        # https://mathiasbynens.github.io/rel-noopener/
        link['rel'] = 'noopener'
      end
      doc.to_html(save_with: 0)
    end

    def trix_content_to_text(html)
      html ||= ''
      HTMLEntities.new.decode(
        ActionController::Base.helpers.strip_tags(
          html.
            gsub(
              /<a.*?href="(.*?)".*?>(.*?)</,
              "\\2 (\\1)<"
            ).
            gsub(
              /<li>(.*?)<\/li>/,
              "- \\1\n"
            ).
            gsub(
              TRIXABLE_TAGS_TO_NEWLINES_REGEX,
              "\n"
            )
        )
      )
    end
  end
end
