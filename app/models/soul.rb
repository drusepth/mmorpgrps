class Soul < ActiveRecord::Base
  belongs_to :player

  STARTING_HEALTH = 100

  def age!
    update_attribute age: (age + 1)
  end

  def move!
    # TODO: logic
    move_randomly!
  end

  private

  def move_randomly!
    new_x_coord = x + (1 - rand(3))
    new_y_coord = y + (1 - rand(3))

    update_attributes({
      x: new_x_coord,
      y: new_y_coord
    })
  end
end
