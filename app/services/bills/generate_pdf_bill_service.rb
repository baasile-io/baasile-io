module Bills
  class GeneratePdfBillService
    REFERENCE_WIDTH = 290
    REFERENCE_UNIT_PRICE_WIDTH = 50
    REFERENCE_UNIT_WIDTH = 50
    REFERENCE_TOTAL_PRICE_WIDTH = 50
    REFERENCE_VAT_RATE_WIDTH = 50
    REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH = 50

    def initialize(bill)
      @font_normal = __dir__ + '/DejaVuSans.ttf'
      @font_bold = __dir__ + '/DejaVuSans-Bold.ttf'
      @logotype_service = LogotypeService.new
      @bill = bill
    end

    def generate_bills_pdf_service_address s, pdf
      name = (s.name.present? ? s.name : s.contactable.name)

      if @logotype_service.exists?(s.contactable.client_id, :tiny)
        pdf.image open(@logotype_service.url(s.contactable.client_id, :tiny)),
                  at: [490, pdf.cursor],
                  scale: 0.5
      end

      pdf.text name,
               size: 12
      pdf.move_down 6

      pdf.text "#{I18n.t('activerecord.attributes.contact_detail.siret')}#{' ' if I18n.locale == :fr}: #{s.siret.present? ? s.siret : '---'}",
               size: 8

      pdf.text "#{I18n.t('activerecord.attributes.contact_detail.chamber_of_commerce')}: #{s.chamber_of_commerce.present? ? s.chamber_of_commerce : '---'}",
               size: 8
      pdf.move_down 6

      pdf.text s.address_line1,
               size: 8

      if s.address_line2.to_s.length > 0
        pdf.text s.address_line2,
                 size: 8
      end
      if s.address_line3.to_s.length > 0
        pdf.text s.address_line3,
                 size: 8
      end

      pdf.text "#{s.zip} #{s.city}",
               size: 8

      if s.country.to_s.length > 0
        pdf.text "#{s.country.upcase}",
                 size: 8
      end

      pdf.move_down 6
      pdf.text "#{I18n.t('activerecord.attributes.contact_detail.phone')}#{' ' if I18n.locale == :fr}: #{s.phone.present? ? s.phone : '---'}",
               size: 8
    end

    def generate_pdf
      pdf_path = File.join(Rails.root, 'tmp', 'tmp.pdf')

      Prawn::Document.generate(pdf_path) do |pdf|
        pdf.font(@font_normal) do

          pdf.font(@font_bold) do
            pdf.text "#{I18n.t('bills.invoice_titles.pdf_title', month: I18n.t("date.month_names")[bill_start_date.month], year: bill_start_date.year)}",
                     size: 20,
                     align: :center
            pdf.move_down 5
            pdf.text "#{I18n.t('bills.invoice_titles.contract_title', contract_id: contract.id)}",
                     size: 16,
                     align: :center
          end
          pdf.move_down pdf.font.height
          pdf.move_down pdf.font.height

          pdf.font(@font_bold) do
            pdf.text "#{I18n.t('bills.invoice_titles.client')}",
                     size: 12
          end
          pdf.stroke_horizontal_rule
          pdf.move_down 8

          generate_bills_pdf_service_address bill.contract.client.contact_detail, pdf
          pdf.move_down pdf.font.height
          pdf.move_down pdf.font.height

          pdf.font(@font_bold) do
            pdf.text "#{I18n.t('bills.invoice_titles.startup')}",
                     size: 12
          end
          pdf.stroke_horizontal_rule
          pdf.move_down 8

          generate_bills_pdf_service_address bill.contract.startup.contact_detail, pdf
          pdf.move_down pdf.font.height * 2

          pdf.font(@font_bold) do
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_reference')}",
                         :at => [0, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         size: 8
            pdf.text_box "#{I18n.t('bills.invoice_attributes.unit_cost')}",
                         :at => [REFERENCE_WIDTH, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_UNIT_PRICE_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         align: :right,
                         size: 8
            pdf.text_box "#{I18n.t('bills.invoice_attributes.unit_num')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_UNIT_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         align: :right,
                         size: 8
            pdf.text_box "#{I18n.t('bills.invoice_attributes.total_cost')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_TOTAL_PRICE_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         align: :right,
                         size: 8
            pdf.text_box "#{I18n.t('bills.invoice_attributes.vat_rate')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_VAT_RATE_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         align: :right,
                         size: 8
            pdf.text_box "#{I18n.t('bills.invoice_attributes.total_cost_including_vat')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH + REFERENCE_VAT_RATE_WIDTH, pdf.cursor + pdf.font.height],
                         :width => REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH,
                         :height => pdf.font.height * 2,
                         valign: :bottom,
                         align: :right,
                         size: 8
          end

          # separator
          pdf.move_down 18
          pdf.stroke_horizontal_rule
          pdf.move_down 5

          bill.bill_lines.each_with_index do |bl, j|
            # bill lines table header
            case bl.line_type.to_sym
              when :amount
                pdf.text_box "#{I18n.t(bl.title, platform_contribution_rate: platform_contribution_rate)}",
                             :at => [0, pdf.cursor],
                             :width => REFERENCE_WIDTH,
                             :height => pdf.font.height,
                             size: 8
                pdf.text_box "#{bl.unit_cost.round(2)}",
                             :at => [REFERENCE_WIDTH, pdf.cursor],
                             :width => REFERENCE_UNIT_PRICE_WIDTH,
                             :height => pdf.font.height,
                             size: 8,
                             align: :right
                pdf.text_box "#{bl.unit_num}",
                             :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH, pdf.cursor],
                             :width => REFERENCE_UNIT_WIDTH,
                             :height => pdf.font.height,
                             size: 8,
                             align: :right
                pdf.text_box "#{(bl.total_cost).round(2)}",
                             :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH, pdf.cursor],
                             :width => REFERENCE_TOTAL_PRICE_WIDTH,
                             :height => pdf.font.height,
                             size: 8,
                             align: :right
                pdf.text_box "#{(bl.vat_rate).round(2)} %",
                             :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH, pdf.cursor],
                             :width => REFERENCE_VAT_RATE_WIDTH,
                             :height => pdf.font.height,
                             size: 8,
                             align: :right
                pdf.text_box "#{(bl.total_cost_including_vat).round(2)}",
                             :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH + REFERENCE_VAT_RATE_WIDTH, pdf.cursor],
                             :width => REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH,
                             :height => pdf.font.height,
                             size: 8,
                             align: :right

                pdf.move_down 12
              when :subtotal
                pdf.font(@font_bold) do
                  pdf.text_box I18n.t('bills.invoice_titles.subtotal'),
                               :at => [0, pdf.cursor],
                               :width => REFERENCE_WIDTH,
                               :height => pdf.font.height,
                               size: 8
                  pdf.text_box "#{(bl.total_cost).round(2)}",
                               :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH, pdf.cursor],
                               :width => REFERENCE_TOTAL_PRICE_WIDTH,
                               :height => pdf.font.height,
                               size: 8,
                               align: :right
                  pdf.text_box "#{(bl.total_cost_including_vat).round(2)}",
                               :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH + REFERENCE_VAT_RATE_WIDTH, pdf.cursor],
                               :width => REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH,
                               :height => pdf.font.height,
                               size: 8,
                               align: :right

                  # separator
                  pdf.move_down 12
                  pdf.stroke_horizontal_rule
                  pdf.move_down 5
                end
              when :supplier
                pdf.font(@font_bold) do
                  pdf.text_box bl.title,
                               :at => [0, pdf.cursor],
                               :width => REFERENCE_WIDTH,
                               :height => pdf.font.height,
                               size: 8

                  # separator
                  pdf.move_down 12
                  pdf.stroke_horizontal_rule
                  pdf.move_down 5
                end
            end

          end

          # calculate total cost for this bill
          pdf.font(@font_bold) do
            pdf.text_box "#{I18n.t('bills.invoice_titles.total')}",
                         :at => [0, pdf.cursor],
                         :width => REFERENCE_WIDTH,
                         :height => pdf.font.height,
                         size: 10
            pdf.text_box "#{bill.total_cost.round(2)}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH, pdf.cursor],
                         :width => REFERENCE_TOTAL_PRICE_WIDTH,
                         :height => pdf.font.height,
                         size: 10,
                         align: :right
            pdf.text_box "#{bill.total_cost_including_vat.round(2)}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH + REFERENCE_VAT_RATE_WIDTH, pdf.cursor],
                         :width => REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH,
                         :height => pdf.font.height,
                         size: 10,
                         align: :right
          end

          pdf.move_down pdf.font.height

          # padding before next bill
          pdf.move_down 30

          # padding before next contract
          pdf.move_down 20
        end
      end

      pdf_path
    end

    def client
      contract.client
    end

    def contract
      bill.contract
    end

    def start_date
      contract.start_date
    end

    def end_date
      contract.end_date
    end

    def price
      contract.price
    end

    def bill_start_date
      bill.start_date
    end

    def lines
      bill.bill_lines
    end

    def bill
      @bill
    end

    def total_cost
      bill.total_cost
    end

    def total_cost_including_vat
      bill.total_cost_including_vat
    end

    def platform_name
      I18n.t('config.platform_name')
    end

    def platform_contribution_rate
      bill.platform_contribution_rate
    end
  end
end
