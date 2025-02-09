class Sector < ActiveRecord::Migration[7.0]
def change
  create_table :sectors do |t|
    t.string   :name
    t.string   :short_name
    t.integer  :head_id

    t.timestamps
    t.integer :created_by
    t.integer :updated_by
    t.boolean :active,  default: true

    t.index :head_id
  end
end

end
