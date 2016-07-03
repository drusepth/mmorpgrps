class Soul < ActiveRecord::Base
  belongs_to :player

  STARTING_HEALTH = 100
  HEALTH_PER_LEVEL_UP = 50

  def age!
    update_attribute :age, age + 1
  end

  def move!
    # TODO: logic
    move_randomly!
  end

  def attack! other_soul
    damage = 50

    case role.downcase
    when 'rock'
      damage *= 2 if other_soul.role.downcase == 'scissors'
      damage /= 2 if other_soul.role.downcase == 'paper'
    when 'paper'
      damage *= 2 if other_soul.role.downcase == 'rock'
      damage /= 2 if other_soul.role.downcase == 'scissors'
    when 'scissors'
      damage *= 2 if other_soul.role.downcase == 'paper'
      damage *= 2 if other_soul.role.downcase == 'rock'
    end

    other_soul.update_attribute :health, other_soul.health - damage
    if other_soul.reload.health <= 0
      level_up!
      other_soul.die!
    end
  end

  def level_up!
    player.update_attribute :souls, player.souls + 1
    update_attributes({
      level: level + 1,
      health: health + HEALTH_PER_LEVEL_UP
    })
  end

  def die!
    update_attributes({
      health: 0,
      alive:  false
    })

    # Return the soul to its owner
    player.update_attribute :souls, player.souls + 1
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
