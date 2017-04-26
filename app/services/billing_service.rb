class BillingService
  class ContractNotStarted < StandardError; end
  class ContractEnded < StandardError; end
  class MissingPriceProxyClient < StandardError; end
  class AlreadyBilled < StandardError; end

  def initialize
    @font_normal = __dir__ + '/DejaVuSans.ttf'
    @font_bold = __dir__ + '/DejaVuSans-Bold.ttf'
  end

  # the month for which to create the bill
  def create_bill contract, bill_month
    if contract.price.nil? || contract.proxy.nil? || contract.client.nil?
      raise MissingPriceProxyClient
    end

    # make sure the bill month is actually a month, not a day
    bill_month = bill_month.beginning_of_month

    if Bill.where(contract: contract, bill_month: bill_month).exists?
      raise AlreadyBilled
    end

    # contract has not yet started: today is before contract start
    next_month_start = (contract.expected_start_date >> 1).beginning_of_month
    if bill_month < next_month_start
      raise ContractNotStarted
    end
    if bill_month > (contract.expected_end_date >> 1).beginning_of_month
      raise ContractEnded
    end

    # lines that will appear on the bill
    lines = Array[]

    # first, add the base cost, pro-rated
    case contract.price.pricing_duration_type.to_sym
    when :prepaid
      # only add the prepaid price on the FIRST bill, not the others
      if bill_month == next_month_start
        lines.push({
          :title => 'services.billing.prepaid_base_cost',
          :unit_cost => contract.price.base_cost.to_f,
          :unit_num => 1
        })
      else
        lines.push({
          :title => 'services.billing.prepaid_base_cost_paid',
          :unit_cost => 0,
          :unit_num => 1
        })
      end
    when :monthly
      prorata = calculate_prorata(
        bill_month,
        contract.expected_start_date,
        contract.expected_end_date
      )

      lines.push({
        :title => 'services.billing.monthly_base_cost',
        :unit_cost => contract.price.base_cost.to_f * prorata,
        :unit_num => 1
      })
    when :yearly
      prorata = calculate_prorata(
        bill_month,
        contract.expected_start_date,
        contract.expected_end_date
      )

      # how big is the billable month compared to the entire year of the contract ?
      # we could divide a 1 year contract by 12, but that would be inaccurate because
      # some months are longer than others
      num_days_in_months = (bill_month << 1).end_of_month.mday
      contract_duration = contract.expected_end_date - contract.expected_start_date
      month_ratio = contract_duration / num_days_in_months.to_f

      lines.push({
        :title => 'services.billing.yearly_base_cost',
        :unit_cost => contract.price.base_cost.to_f / month_ratio * prorata,
        :unit_num => 1
      })
    end

    # some contracts have usage limits, so we'll check those here
    measurements = Measurement.by_client(contract.client).by_proxy(contract.proxy).by_startup(contract.startup)

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
      lines.push({
        :title => case contract.price.pricing_type.to_sym
          when :per_call
            'services.billing.additional_requests_cost'
          when :per_parameter
            'services.billing.additional_measure_tokens_cost'
        end,
        :unit_cost => contract.price.unit_cost.to_f,
        :unit_num => additional_units
      })
    end

    bill = Bill.new
    bill.contract = contract
    bill.bill_month = bill_month
    lines.each do |l|
      bill_line = BillLine.new do |bl|
        bl.title = l[:title]
        bl.unit_cost = l[:unit_cost]
        bl.unit_num = l[:unit_num]
      end
      bill.bill_lines.push bill_line
    end
    contract.bills.push bill
    contract.save
  end

  def generate_bills_pdf_service_address s, pdf
    pdf.font(@font_bold) do
      pdf.text "#{I18n.t('services.billing.pdf.address')}"
    end
    if s.name.to_s.length > 0
      pdf.text s.name
    end
    if s.siret.to_s.length > 0
      pdf.text "SIRET: #{s.siret}"
    end
    if s.chamber_of_commerce.to_s.length > 0
      pdf.text "#{I18n.t('services.billing.pdf.chamber_of_commerce')}: #{s.chamber_of_commerce}"
    end
    if s.address_line1.to_s.length > 0
      pdf.text s.address_line1
    end
    if s.address_line2.to_s.length > 0
      pdf.text s.address_line2
    end
    if s.address_line3.to_s.length > 0
      pdf.text s.address_line3
    end
    if s.zip.to_s.length > 0 && s.city.to_s.length > 0
      pdf.text "#{s.zip} #{s.city}"
    end
    if s.country.to_s.length > 0
      pdf.text "#{s.country.upcase}"
    end

    if s.phone.to_s.length > 0
      pdf.font(@font_bold) do
        pdf.text "#{I18n.t('services.billing.pdf.contact')}"
      end
    end
    if s.phone.to_s.length > 0
      pdf.text "#{I18n.t('services.billing.pdf.phone')}: #{s.phone}"
    end
  end

  def generate_bills_pdf client, bill_month
    bill_month = bill_month.beginning_of_month

    Prawn::Document.generate("/tmp/bill.pdf") do |pdf|
      pdf.font(@font_normal) do

        pdf.font(@font_bold) do
          pdf.text "#{I18n.t('services.billing.pdf.title', month: I18n.t("date.month_names")[bill_month.month], year: bill_month.year)}",
            :size => 20,
            :align => :center
        end
        pdf.move_down pdf.font.height
        pdf.move_down pdf.font.height

        generate_bills_pdf_service_address client.contact_detail, pdf
        pdf.move_down pdf.font.height
        pdf.move_down pdf.font.height

        Contract.where(client: client).each_with_index do |c, i|
          pdf.text "#{I18n.t('services.billing.pdf.contract')} ##{i + 1} - #{I18n.t('services.billing.pdf.company')} \"#{c.startup.name}\""
          pdf.stroke_horizontal_rule
          pdf.move_down pdf.font.height
          pdf.move_down pdf.font.height

          generate_bills_pdf_service_address c.startup.contact_detail, pdf
          pdf.move_down pdf.font.height
          pdf.move_down pdf.font.height

          if c.bills.select { |b| b.bill_month == bill_month }.length == 0
            pdf.text "#{I18n.t('services.billing.pdf.no_bill', month: I18n.t("date.month_names")[bill_month.month], year: bill_month.year)}"
            pdf.move_down 50
            next
          end

          c.bills.each_with_index do |b, j|
            # only display the bills for the given month
            if b.bill_month != bill_month
              next
            end

            # bill lines table header
            pdf.font(@font_bold) do
              pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_reference')}",
                :at => [0, pdf.cursor],
                :width => 350,
                :height => pdf.font.height
              pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_unit_num')}",
                :at => [350, pdf.cursor],
                :width => 50,
                :height => pdf.font.height
              pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_unit_cost')}",
                :at => [400, pdf.cursor],
                :width => 75,
                :height => pdf.font.height
              pdf.text_box "#{I18n.t('services.billing.pdf.bill_line_total')}",
                :at => [475, pdf.cursor],
                :width => 75,
                :height => pdf.font.height
            end

            # separator
            pdf.move_down pdf.font.height
            pdf.stroke_horizontal_rule
            pdf.move_down 5

            # bill lines table body
            b.bill_lines.each_with_index do |bl, k|
              pdf.text_box "#{I18n.t(bl.title)}", :at => [0, pdf.cursor], :width => 350, :height => pdf.font.height
              pdf.text_box "#{bl.unit_num}", :at => [350, pdf.cursor], :width => 50, :height => pdf.font.height
              pdf.text_box "#{bl.unit_cost.round(2)}€", :at => [400, pdf.cursor], :width => 50, :height => pdf.font.height
              pdf.text_box "#{(bl.unit_num * bl.unit_cost).round(2)}€", :at => [475, pdf.cursor], :width => 50, :height => pdf.font.height
              pdf.move_down pdf.font.height
            end

            # separator
            pdf.stroke_horizontal_rule
            pdf.move_down 5

            # calculate total cost for this bill
            total_cost = b.bill_lines.map {|bl| bl.unit_num * bl.unit_cost}.reduce(:+)
            pdf.text_box "#{I18n.t('services.billing.pdf.total')}", :at => [0, pdf.cursor], :width => 350, :height => pdf.font.height
            pdf.text_box "#{total_cost.round(2)}€", :at => [475, pdf.cursor], :width => 75, :height => pdf.font.height
            pdf.move_down pdf.font.height
            pdf.stroke_horizontal_rule

            # padding before next bill
            pdf.move_down 30
          end

          # padding before next contract
          pdf.move_down 20
        end
      end
    end
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
end
