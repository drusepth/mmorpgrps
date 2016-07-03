class CreateSouls < ActiveRecord::Migration
  def change
    create_table :souls do |t|
      t.string :role
      t.boolean :alive
      t.integer :x
      t.integer :y
      t.float :health
      t.integer :level

      t.timestamps null: false
    end
  end
end
