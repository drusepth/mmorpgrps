class AddAgeToSoul < ActiveRecord::Migration
  def change
    add_column :souls, :age, :integer
  end
end
