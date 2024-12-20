class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :total, precision: 10, scale: 2
      t.string :status, default: 'Pending'
      t.date :issue_date
      t.date :due_date

      t.timestamps
    end
  end
end
