module AmountsHelper
  include ActionView::Helpers::NumberHelper

  def to_cur(amount, precision = 2, unit = '')
    (amount == 0) ? 0.0 : number_to_currency(amount, precision: precision, unit: unit)
  end

  def format_amount(amount)
    "#{to_cur amount} €"
  end

  def format_rate(rate)
    "#{to_cur rate} %"
  end
end