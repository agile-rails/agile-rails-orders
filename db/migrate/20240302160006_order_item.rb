class OrderItem < ActiveRecord::Migration[7.0]

def change
  create_table :order_items do |t|
    t.references :order
    t.string     :name
    t.string     :uom
    t.string     :amount
    t.decimal    :price
    t.decimal    :value

    t.timestamps
    t.integer :created_by
    t.integer :updated_by
  end
end

end
