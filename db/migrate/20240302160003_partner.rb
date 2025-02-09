class Partner < ActiveRecord::Migration[7.0]
def change
  create_table :partners do |t|
    t.string  :name
    t.string  :name_long
    t.string  :address
    t.string  :post
    t.string  :country
    t.string  :email
    t.string  :phone
    t.string  :mobile
    t.string  :account
    t.string  :vat_number
    t.text    :notes

    t.timestamps
    t.integer :created_by
    t.integer :updated_by
    t.boolean :active,  default: true

    t.index :vat_number
  end

end

end
