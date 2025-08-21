module Admin::ReportsHelper
  def format_date_range(period)
    date_range = get_date_range(period)
    return "All Time" if date_range.nil?

    start_date = date_range.begin.strftime("%b %d, %Y")
    end_date = date_range.end.strftime("%b %d, %Y")

    if start_date == end_date
      start_date
    else
      "#{start_date} - #{end_date}"
    end
  end
end
