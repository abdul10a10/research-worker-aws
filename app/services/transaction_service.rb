class TransactionService

  def self.total_monthly_transaction
    total_transaction = 0
    total_payment = 0
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    monthly_transaction = Array.new
    monthly_payment = Array.new
    i=0

    loop do
      paid_studies = Study.where(created_at: start_time..end_time, is_paid: "1").order(id: :desc)
      paid_amount = 0
      transaction_count = 0
      paid_studies.each do |study|
        transaction = study.transactions.where(payment_type: "Study Payment").first
        if transaction.present?
          paid_amount = paid_amount + transaction.try(:amount)
          transaction_count +=1
        end
      end
      total_payment += paid_amount
      monthly_payment.push(sprintf('%.2f', paid_amount))
      monthly_transaction.push(transaction_count)
      total_transaction += transaction_count
      
      end_time = start_time
      start_time = start_time-1.month
      i += 1
      if i == 12
        break       
      end
    end
    data = { total_transaction: total_transaction,
      monthly_transaction: monthly_transaction.reverse,
      monthly_payment: monthly_payment.reverse,
      total_payment: total_payment
    }
  end
  
end