class FunctionService
  def self.month_array
    month = Array.new
    start_time = Time.now.beginning_of_month
    i = 0  
    loop do
      month.push(start_time.strftime("%B"))
      start_time = start_time-1.month
      i += 1
      if i == 12
        break       
      end
    end
    month.reverse
  end
end