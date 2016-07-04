class AddSoulBountyToSoul < ActiveRecord::Migration
  def change
    add_column :souls, :soul_bounty, :integer, default: 0
  end
end
