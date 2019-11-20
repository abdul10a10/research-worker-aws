class AddOrderIdToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :order_id, :string
  end
end
