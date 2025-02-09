class CostCenter < ActiveRecord::Migration[7.0]
def change
  create_table :cost_centers do |t|
    t.string  :code
    t.string  :name
    t.integer :sector_id
    t.integer :center_type
    #1:Primary,2:Secondary
    t.integer :ar_user_id

    t.timestamps
    t.integer :created_by
    t.integer :updated_by
    t.boolean :active,  default: true
  end
end

end
