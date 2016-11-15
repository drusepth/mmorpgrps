class CreateWorlds < ActiveRecord::Migration
  def change
    create_table :worlds do |t|
      t.integer :height
      t.integer :width

      t.timestamps null: false
    end
  end
end
