class BillingService
  class ContractNotStarted < StandardError; end
  class ContractEnded < StandardError; end
  class MissingPriceProxyClient < StandardError; end
  class AlreadyBilled < StandardError; end

  def initialize
    @font_normal = __dir__ + '/DejaVuSans.ttf'
    @font_bold = __dir__ + '/DejaVuSans-Bold.ttf'

    # lines that will appear on the bill
    @lines = []
  end

  def calculate(contract, bill_month)
    # make sure the bill month is actually a month, not a day
    @contract = contract
    @bill_month = bill_month.beginning_of_month

    if contract.price.nil? || contract.proxy.nil? || contract.client.nil?
      raise MissingPriceProxyClient
    end

    calculate_lines
    push_subtotal_line
    calculate_contribution
    push_subtotal_line

    bill
  end

  def calculate_contribution
    push_line({
                title: platform_name,
                line_type: :supplier
              })

    push_line({
                title: 'contribution',
                unit_cost: total_cost * platform_contribution_rate / 100.0,
                unit_num: 1
              })
  end

  def calculate_lines
    push_line({
                title: contract.proxy.name,
                line_type: :supplier
              })

    # first, add the base cost, pro-rated
    case contract.price.pricing_duration_type.to_sym
      when :prepaid
        # only add the prepaid price on the FIRST bill, not the others
        if bill_month == next_month_start
          push_line({
                      title: 'services.billing.prepaid_base_cost',
                      unit_cost: contract.price.base_cost.to_f,
                      unit_num: 1
                    })
        else
          push_line({
                      title: 'services.billing.prepaid_base_cost_paid',
                      unit_cost: 0,
                      unit_num: 1
                    })
        end
      when :monthly
        prorata = calculate_prorata(
          bill_month,
          contract.start_date,
          contract.end_date
        )

        push_line({
                    title: 'services.billing.monthly_base_cost',
                    unit_cost: contract.price.base_cost.to_f * prorata,
                    unit_num: 1
                  })
      when :yearly
        prorata = calculate_prorata(
          bill_month,
          contract.start_date,
          contract.end_date
        )

        # how big is the billable month compared to the entire year of the contract ?
        # we could divide a 1 year contract by 12, but that would be inaccurate because
        # some months are longer than others
        num_days_in_months = (bill_month << 1).end_of_month.mday
        contract_duration = contract.end_date - contract.start_date
        month_ratio = contract_duration / num_days_in_months.to_f

        push_line({
                    title: 'services.billing.yearly_base_cost',
                    unit_cost: contract.price.base_cost.to_f / month_ratio * prorata,
                    unit_num: 1
                  })
    end

    # some contracts have usage limits, so we'll check those here
    measurements = Measurement.by_contract_status(contract)

    # get requests for the billable period of time
    measurement_month = bill_month << 1
    case contract.price.pricing_duration_type.to_sym
      when :monthly
        measurements = measurements.where(
          'created_at >= :start AND created_at <= :end',
          start: measurement_month.beginning_of_month,
          end: measurement_month.end_of_month
        )
      when :yearly
        measurements = measurements.where(
          'created_at >= :start AND created_at <= :end',
          start: measurement_month.beginning_of_year,
          end: measurement_month.end_of_year
        )
    end

    # check if the client had more usage than allowed by default
    additional_units = -contract.price.free_count
    case contract.price.pricing_type.to_sym
      when :per_call
        # get the number of requests for this months or this year
        if !contract.price.route.nil?
          additional_units += measurements.by_route(contract.price.route).sum(:requests_count)
        else
          additional_units += measurements.sum(:requests_count)
        end
      when :per_parameter
        # get number of measuretokens for requests of this months or this year
        additional_units += measurements.where.not(measure_token_id: nil).select(:measure_token_id).distinct.count
    end

    # adds the additional unit cost to the bill
    if additional_units > 0
      push_line({
                  title: case contract.price.pricing_type.to_sym
                           when :per_call
                             'services.billing.additional_requests_cost'
                           when :per_parameter
                             'services.billing.additional_measure_tokens_cost'
                         end,
                  unit_cost: contract.price.unit_cost.to_f,
                  unit_num: additional_units
                })
    end
  end

  # the month for which to create the bill
  def create_bill
    if Bill.where(contract: contract, bill_month: bill_month).exists?
      raise AlreadyBilled
    end

    # contract has not yet started: today is before contract start
    next_month_start = (contract.start_date >> 1).beginning_of_month
    if bill_month < next_month_start
      raise ContractNotStarted
    end
    if bill_month > (contract.end_date >> 1).beginning_of_month
      raise ContractEnded
    end

    bill = Bill.new(
      contract: contract,
      bill_month: bill_month
    )

    lines.each do |bill_line|
      bill.bill_lines.push bill_line
    end

    bill.total_cost = total_cost
    bill.total_cost_including_vat = total_cost_including_vat
    bill.total_vat = total_cost_including_vat - total_cost

    contract.bills.push bill
    contract.save
  end

  def generate_bills_pdf_service_address s, pdf
    name = (s.name.present? ? s.name : s.contactable.name)
    if name.length > 0
      pdf.text name,
               size: 12
    end
    if s.siret.to_s.length > 0
      pdf.text "SIRET: #{s.siret}",
               size: 10
    end
    if s.chamber_of_commerce.to_s.length > 0
      pdf.text "#{I18n.t('services.billing.pdf.chamber_of_commerce')}: #{s.chamber_of_commerce}",
               size: 10
    end
    if s.address_line1.to_s.length > 0
      pdf.text s.address_line1,
               size: 10
    end
    if s.address_line2.to_s.length > 0
      pdf.text s.address_line2,
               size: 10
    end
    if s.address_line3.to_s.length > 0
      pdf.text s.address_line3,
               size: 10
    end
    if s.zip.to_s.length > 0 && s.city.to_s.length > 0
      pdf.text "#{s.zip} #{s.city}",
               size: 10
    end
    if s.country.to_s.length > 0
      pdf.text "#{s.country.upcase}",
               size: 10
    end

    if s.phone.to_s.length > 0
      pdf.move_down 6
      pdf.text "#{I18n.t('services.billing.pdf.phone')}: #{s.phone}",
               size: 10
    end
  end

  REFERENCE_WIDTH = 290
  REFERENCE_UNIT_PRICE_WIDTH = 50
  REFERENCE_UNIT_WIDTH = 50
  REFERENCE_TOTAL_PRICE_WIDTH = 50
  REFERENCE_VAT_RATE_WIDTH = 50
  REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH = 50

  def generate_pdf
    pdf_path = File.join(Rails.root, 'tmp', 'tmp.pdf')

    Prawn::Document.generate(pdf_path) do |pdf|
      pdf.font(@font_normal) do

        pdf.font(@font_bold) do
          pdf.text "#{I18n.t('services.billing.pdf.title', month: I18n.t("date.month_names")[bill_month.month], year: bill_month.year)}",
            :size => 20,
            :align => :center
        end
        pdf.move_down pdf.font.height
        pdf.move_down pdf.font.height

        generate_bills_pdf_service_address bill.contract.client.contact_detail, pdf
        pdf.move_down pdf.font.height
        pdf.move_down pdf.font.height

        Array(bill).each_with_index do |bill, i|
          pdf.font(@font_bold) do
            pdf.text "#{I18n.t('services.billing.pdf.contract')} ##{i + 1} - #{I18n.t('services.billing.pdf.company')} \"#{bill.contract.startup.name}\"",
                     size: 12
          end
          pdf.stroke_horizontal_rule
          pdf.move_down pdf.font.height

          generate_bills_pdf_service_address bill.contract.startup.contact_detail, pdf
          pdf.move_down pdf.font.height

          if bill.total_cost == 0
            pdf.text "#{I18n.t('services.billing.pdf.no_bill', month: I18n.t("date.month_names")[bill_month.month], year: bill_month.year)}"
            pdf.move_down 50
            next
          end

          pdf.font(@font_bold) do
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_reference')}",
                         :at => [0, pdf.cursor],
                         :width => REFERENCE_WIDTH,
                         :height => pdf.font.height,
                         size: 8
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_unit_cost')}",
                         :at => [REFERENCE_WIDTH, pdf.cursor],
                         :width => REFERENCE_UNIT_PRICE_WIDTH,
                         :height => pdf.font.height,
                         size: 8
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_unit_num')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH, pdf.cursor],
                         :width => REFERENCE_UNIT_WIDTH,
                         :height => pdf.font.height,
                         size: 8
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_total')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH, pdf.cursor],
                         :width => REFERENCE_TOTAL_PRICE_WIDTH,
                         :height => pdf.font.height,
                         size: 8
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_total')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH, pdf.cursor],
                         :width => REFERENCE_VAT_RATE_WIDTH,
                         :height => pdf.font.height,
                         size: 8
            pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_total')}",
                         :at => [REFERENCE_WIDTH + REFERENCE_UNIT_PRICE_WIDTH + REFERENCE_UNIT_WIDTH + REFERENCE_TOTAL_PRICE_WIDTH + REFERENCE_VAT_RATE_WIDTH, pdf.cursor],
                         :width => REFERENCE_TOTAL_PRICE_INCLUDING_VAT_WIDTH,
                         :height => pdf.font.height,
                         size: 8
          end

          # separator
          pdf.move_down 12
          pdf.stroke_horizontal_rule
          pdf.move_down 5

          bill.bill_lines.each_with_index do |bl, j|
            # bill lines table header
            case bl.line_type.to_sym
              when :amount
                pdf.text_box "#{I18n.t(bl.title)}",
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
                  pdf.text_box "Subtotal",
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
            pdf.text_box "#{I18n.t('services.billing.pdf.total')}",
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
    end

    pdf_path
  end

  def calculate_prorata bill_month, start_date, end_date
    last_day = (bill_month - 1)
    first_day = (bill_month - 1).beginning_of_month
    num_days = last_day.mday

    start_date = start_date.beginning_of_day.to_date
    end_date = end_date.beginning_of_day.to_date

    if first_day <= end_date && last_day >= end_date
      # last month prorated
      ((end_date - first_day) + 1) / num_days.to_f
    elsif first_day <= start_date && last_day >= start_date
      # first month prorated
      ((last_day - start_date) + 1) / num_days.to_f
    else
      1.0
    end
  end

  def push_line(data)
    data[:vat_rate] ||= vat_rate
    bill_line = BillLine.new(data)
    bill_line.valid?
    increase_total bill_line.total_cost, bill_line.total_cost_including_vat
    lines.push bill_line
  end

  def push_subtotal_line
    bill_line = BillLine.new({
                               line_type: :subtotal,
                               total_cost: subtotal,
                               total_cost_including_vat: subtotal_including_vat
                             })
    lines.push bill_line
    @subtotal = 0.0
    @subtotal_including_vat = 0.0
  end

  def subtotal
    @subtotal ||= 0.0
  end

  def subtotal_including_vat
    @subtotal_including_vat ||= 0.0
  end

  def client
    @contract.client
  end

  def contract
    @contract
  end

  def bill_month
    @bill_month
  end

  def lines
    bill.bill_lines
  end

  def increase_total(amount, amount_including_vat)
    bill.total_cost = bill.total_cost + amount
    bill.total_cost_including_vat = bill.total_cost_including_vat + amount_including_vat
    @subtotal = subtotal + amount
    @subtotal_including_vat = subtotal_including_vat + amount_including_vat
  end

  def bill
    @bill ||= Bill.new(contract: contract, bill_month: bill_month)
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
    @contribution_rate ||= Appconfig.get(:platform_contribution_rate)
  end

  def vat_rate
    @vat_rate ||= Appconfig.get(:vat_rate)
  end
end
