class AddWorldIdToPlayer < ActiveRecord::Migration
  def change
    add_reference :players, :world, index: true, foreign_key: true
  end
end
