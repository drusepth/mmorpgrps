class Soul < ActiveRecord::Base
  belongs_to :player

  STARTING_HEALTH          = 100
  HEALTH_PER_LEVEL_UP      = 50
  VISION_RANGE             = 2
  BASE_ATTACK_DAMAGE       = 50
  STRONG_ATTACK_MULTIPLIER = 2
  WEAK_ATTACK_DIVIDER      = 2

  def age!
    self.age = age + 1
  end

  def move!
    move_randomly!
    #swarm_nearest_faction!
  end

  def attack! other_soul
    damage = BASE_ATTACK_DAMAGE

    case role.downcase
    when 'rock'
      damage *= STRONG_ATTACK_MULTIPLIER if other_soul.role.downcase == 'scissors'
      damage /= WEAK_ATTACK_DIVIDER      if other_soul.role.downcase == 'paper'
    when 'paper'
      damage *= STRONG_ATTACK_MULTIPLIER if other_soul.role.downcase == 'rock'
      damage /= WEAK_ATTACK_DIVIDER      if other_soul.role.downcase == 'scissors'
    when 'scissors'
      damage *= STRONG_ATTACK_MULTIPLIER if other_soul.role.downcase == 'paper'
      damage /= WEAK_ATTACK_DIVIDER      if other_soul.role.downcase == 'rock'
    end

    other_soul.health = other_soul.health - damage
    if other_soul.health <= 0
      level_up!
      other_soul.die!
    end
  end

  def level_up!
    player.update_attribute :souls, player.souls + 1
    self.level += 1
    self.health += HEALTH_PER_LEVEL_UP
  end

  def die!
    self.health = 0
    self.alive = false

    # Refund the soul to its owner
    player.update_attribute :souls, player.souls + 1
  end

  private

  def move_randomly!
    new_x_coord = x + (1 - rand(3))
    new_y_coord = y + (1 - rand(3))

    self.x = new_x_coord
    self.y = new_y_coord

    self.save!
  end

  def swarm_nearest_faction!
    faction_souls_nearby = Soul.where(
      alive: true,
      role: role,
      x: (x - VISION_RANGE)..(x + VISION_RANGE),
      y: (y - VISION_RANGE)..(y + VISION_RANGE)
    ).where.not(
      id: id
    )

    soul_to_swarm_to = faction_souls_nearby.sample
    return move_randomly! unless soul_to_swarm_to.present?

    new_x_coord = x
    new_x_coord += (1 - rand(2)) if soul_to_swarm_to.x > x
    new_x_coord -= (1 - rand(2)) if soul_to_swarm_to.x < x

    new_y_coord = y
    new_y_coord += (1 - rand(2)) if soul_to_swarm_to.y > y
    new_y_coord -= (1 - rand(2)) if soul_to_swarm_to.y < y

    self.x = new_x_coord
    self.y = new_y_coord
  end
end
