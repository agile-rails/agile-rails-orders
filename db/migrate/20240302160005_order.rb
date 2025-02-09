class Order < ActiveRecord::Migration[7.0]

def change
  create_table :orders do |t|
    t.string     :doc_number
    t.string     :order_number
    t.string     :name
    t.references :proposer, foreign_key: { to_table: :ar_users }
    t.references :signer, foreign_key: { to_table: :ar_users }
    t.references :sector
    t.references :cost_center
    t.text       :reason
    t.references :partner
    t.datetime   :proposed_date
    t.datetime   :creation_date
    t.text       :comment
    t.string     :currency
    t.decimal    :value,  default: 0.0

    t.timestamps
    t.integer :created_by
    t.integer :updated_by
  end
end

end
