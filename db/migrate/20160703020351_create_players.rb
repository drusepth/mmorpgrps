class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.integer :free_souls, default: 10

      t.timestamps null: false
    end
  end
end
