class RenameCompareAtToCompared < ActiveRecord::Migration[7.0]
  def change
    rename_column :aypex_prices, :compare_at_amount, :compared_amount
  end
end
