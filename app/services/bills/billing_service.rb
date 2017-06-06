module Bills
  class BillingService

    class ContractNotStartedError < StandardError; end
    class ContractEndedError < StandardError; end
    class MissingPriceProxyClientError < StandardError; end
    class InvalidBillRecordError < StandardError; end
    class MissingPreviousBillMonth < StandardError; end

    def initialize(contract, bill_start_date)
      @contract = contract
      @bill_start_date = bill_start_date
      @bill_end_date = bill_start_date
      @bill_duration = 1
      @lines = []
    end

    def prepare
      if price.nil? || proxy.nil? || client.nil?
        raise MissingPriceProxyClientError
      end

      prepare_start_and_end_dates
      calculate_lines
      push_subtotal_line
      calculate_contribution
      push_subtotal_line

      bill
    end

    def call(due_date = Date.today + Appconfig.get(:bill_payment_deadline).days)
      bill.due_date = due_date
      bill.paid = true if total_cost == 0

      bill.total_cost = total_cost
      bill.total_cost_including_vat = total_cost_including_vat
      bill.total_vat = total_cost_including_vat - total_cost

      bill.save!
    rescue ActiveRecord::RecordInvalid
      raise InvalidBillRecordError
    end

    private

      attr_reader   :contract, :bill_start_date, :bill_end_date, :bill_duration

      def prepare_start_and_end_dates
        if contract.start_date >= bill_start_date
          raise ContractNotStartedError
        end
        if bill_start_date > contract.end_date
          raise ContractEndedError
        end

        chk_start_date = contract.start_date
        while chk_start_date + 1.month < bill_start_date
          chk_start_date = chk_start_date + 1.month
        end
        @bill_start_date = chk_start_date
        @bill_end_date   = if chk_start_date + 1.month > contract.end_date
                             contract.end_date
                           else
                             chk_start_date + 1.month - 1.day
                           end
        @bill_duration   = (bill_end_date - bill_start_date).to_i + 1
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
            if bill_start_date == contract.start_date
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

            month_ratio = bill_duration / (end_date - (end_date - 1.year)).to_f

            push_line({
                        title: 'services.billing.yearly_base_cost',
                        unit_cost: price.base_cost.to_f * month_ratio * prorata,
                        unit_num: 1
                      })
        end

        measurements = Measurement.by_contract_status(contract)

        # check if the client had more usage than allowed by default
        additional_units = -price.free_count
        current_month_units = 0
        unless price.deny_after_free_count
          case price.pricing_type.to_sym
            when :per_call
              # get the number of requests for this months or this year
              scope = measurements
              if !price.route.nil?
                scope = scope.by_route(price.route)
              end
              current_month_units = scope.between(bill_start_date, bill_end_date).sum(:requests_count)
              additional_units += scope.sum(:requests_count)
            when :per_parameter
              # get number of measuretokens for requests of this months or this year
              scope = measurements.where.not(measure_token_id: nil).select(:measure_token_id)
              current_month_units = scope.between(bill_start_date, bill_end_date).distinct.count
              additional_units += scope.distinct.count
          end
        end

        # adds the additional unit cost to the bill
        if additional_units > 0
          additional_units = [additional_units, current_month_units].min
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

      def calculate_prorata
        if bill_start_date + 1.month > bill_end_date
          num_days = (bill_start_date + 1.month - bill_start_date).to_i + 1
          ((bill_end_date - bill_start_date).to_i + 1) / num_days.to_f
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
          start_date: bill_start_date,
          end_date: bill_end_date,
          duration: bill_duration,
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
        @contribution_rate ||= Appconfig.get(:bill_platform_contribution_rate)
      end

      def vat_rate
        @vat_rate ||= Appconfig.get(:vat_rate)
      end

  end
end