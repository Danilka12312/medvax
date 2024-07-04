# app/helpers/pages_helper.rb
module PagesHelper
  def next_three_months
    (0..2).map do |i|
      month = Time.current.beginning_of_month + i.months
      [month.strftime("%B %Y"), month.strftime("%Y-%m")]
    end
  end
end
