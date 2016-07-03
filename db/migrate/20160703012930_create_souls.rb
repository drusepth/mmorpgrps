class CreateSouls < ActiveRecord::Migration
  def change
    create_table :souls do |t|
      t.string :class
      t.references :player, index: true, foreign_key: true
      t.boolean :alive
      t.integer :x
      t.integer :y
      t.float :health
      t.integer :level

      t.timestamps null: false
    end
  end
end
