module Bills
  class BillingService
    class ContractNotStarted < StandardError; end
    class ContractEnded < StandardError; end
    class MissingPriceProxyClient < StandardError; end
    class AlreadyBilled < StandardError; end

    def initialize(contract, bill_month)
      @contract = contract
      @bill_month = bill_month.beginning_of_month
      @lines = []
    end

    def calculate
      if price.nil? || proxy.nil? || client.nil?
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
                  title: 'bills.invoice_titles.platform_contribution',
                  unit_cost: total_cost * platform_contribution_rate / 100.0,
                  unit_num: 1
                })
    end

    def calculate_lines
      push_line({
                  title: proxy.name,
                  line_type: :supplier
                })

      # first, add the base cost, pro-rated
      case price.pricing_duration_type.to_sym
        when :prepaid
          # only add the prepaid price on the FIRST bill, not the others
          next_month_start = (contract.start_date >> 1).beginning_of_month
          if bill_month == next_month_start
            push_line({
                        title: 'services.billing.prepaid_base_cost',
                        unit_cost: price.base_cost.to_f,
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
          prorata = calculate_prorata

          push_line({
                      title: (prorata == 1 ? 'services.billing.monthly_base_cost' : 'services.billing.monthly_base_cost_prorated'),
                      unit_cost: price.base_cost.to_f * prorata,
                      unit_num: 1
                    })
        when :yearly
          prorata = calculate_prorata

          # how big is the billable month compared to the entire year of the contract ?
          # we could divide a 1 year contract by 12, but that would be inaccurate because
          # some months are longer than others
          num_days_in_months = (bill_month << 1).end_of_month.mday
          contract_duration = (end_date - start_date).to_i
          month_ratio = num_days_in_months / contract_duration.to_f

          push_line({
                      title: 'services.billing.yearly_base_cost',
                      unit_cost: price.base_cost.to_f * month_ratio * prorata,
                      unit_num: 1
                    })
      end

      # some contracts have usage limits, so we'll check those here
      measurements = Measurement.by_contract_status(contract)

      # get requests for the billable period of time
      measurement_month = bill_month << 1
      case price.pricing_duration_type.to_sym
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
      additional_units = -price.free_count
      case price.pricing_type.to_sym
        when :per_call
          # get the number of requests for this months or this year
          if !price.route.nil?
            additional_units += measurements.by_route(price.route).sum(:requests_count)
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
                    title: case price.pricing_type.to_sym
                             when :per_call
                               'services.billing.additional_requests_cost'
                             when :per_parameter
                               'services.billing.additional_measure_tokens_cost'
                           end,
                    unit_cost: price.unit_cost.to_f,
                    unit_num: additional_units
                  })
      end
    end

    # the month for which to create the bill
    def create_bill(due_date)
      # contract has not yet started: today is before contract start
      next_month_start = (contract.start_date >> 1).beginning_of_month
      if contract.start_date >= next_month_start
        raise ContractNotStarted
      end
      if bill_month > contract.end_date
        raise ContractEnded
      end

      bill.due_date = due_date

      bill.total_cost = total_cost
      bill.total_cost_including_vat = total_cost_including_vat
      bill.total_vat = total_cost_including_vat - total_cost

      bill.save!
    end

    def calculate_prorata
      last_day = bill_month.end_of_month
      first_day = bill_month
      num_days = last_day.mday

      if first_day <= end_date && last_day >= end_date
        # last month prorated
        ((end_date - first_day).to_i + 1) / num_days.to_f
      elsif first_day <= start_date && last_day >= start_date
        # first month prorated
        ((last_day - start_date).to_i + 1) / num_days.to_f
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
      contract.client
    end

    def contract
      @contract
    end

    def proxy
      contract.proxy
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
      @bill ||= Bill.new(
        contract: contract,
        bill_month: bill_month,
        platform_contribution_rate: platform_contribution_rate
      )
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
end