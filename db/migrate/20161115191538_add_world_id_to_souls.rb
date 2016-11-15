class AddWorldIdToSouls < ActiveRecord::Migration
  def change
    add_reference :souls, :world, index: true, foreign_key: true
  end
end
