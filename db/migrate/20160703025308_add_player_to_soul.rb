class AddPlayerToSoul < ActiveRecord::Migration
  def change
    add_reference :souls, :player, index: true, foreign_key: true
  end
end
