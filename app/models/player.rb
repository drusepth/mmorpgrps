class Player < ActiveRecord::Base
  belongs_to :world
  has_many :souls
end
