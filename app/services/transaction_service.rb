class TransactionService

  def self.total_monthly_transaction
    total_transaction = 0
    total_payment = 0
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    monthly_transaction = Array.new
    monthly_payment = Array.new
    monthly_indian_payment = Array.new
    monthly_uae_payment = Array.new
    monthly_other_country_payment = Array.new
    i=0

    loop do
      paid_studies = Study.where(created_at: start_time..end_time, is_paid: "1").order(id: :desc)
      paid_amount = 0
      transaction_count = 0
      indian_transactions = 0
      indian_payment = 0
      uae_transactions = 0
      uae_payment = 0
      other_country_transactions = 0
      other_country_payment = 0
      paid_studies.each do |study|
        transaction = study.transactions.where(payment_type: "Study Payment").first
        if transaction.present?
          paid_amount +=  transaction.try(:amount)
          transaction_count +=1

          if study.user.country == "India"
            indian_transactions += 1
            indian_payment += transaction.try(:amount)
          elsif study.user.country == "United Arab Emirates" || study.user.country == "UAE"
            uae_transactions += 1
            uae_payment += transaction.try(:amount)
          else
            other_country_transactions += 1
            other_country_payment += transaction.try(:amount)
          end

        end
      end
      total_payment += paid_amount
      monthly_payment.push(sprintf('%.2f', paid_amount))
      monthly_indian_payment.push(sprintf('%.2f',indian_payment))
      monthly_uae_payment.push(sprintf('%.2f',uae_payment))
      monthly_other_country_payment.push(sprintf('%.2f',other_country_payment))
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
      monthly_uae_payment: monthly_uae_payment.reverse,
      monthly_other_country_payment: monthly_other_country_payment.reverse,
      monthly_indian_payment: monthly_indian_payment.reverse,

      total_payment: sprintf('%.2f', total_payment)
    }
  end
  
end