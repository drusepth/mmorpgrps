class Soul < ActiveRecord::Base
  belongs_to :player
  belongs_to :world

  STARTING_HEALTH          = 100
  HEALTH_PER_LEVEL_UP      = 50
  VISION_RANGE             = 1
  BASE_ATTACK_DAMAGE       = 50
  STRONG_ATTACK_MULTIPLIER = 2
  WEAK_ATTACK_DIVIDER      = 2

  def age!
    self.age = age + 0.1
  end

  def move!
    #move_randomly!
    swarm_nearest_faction!
    #swarm_nearest_soul!
  end

  def attack! other_soul
    damage = BASE_ATTACK_DAMAGE

    case role.split(' ').first.downcase
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

      # Claim soul bounties
      if other_soul.soul_bounty > 0
        player.update_attribute :free_souls, player.free_souls + other_soul.soul_bounty
      end
    end
  end

  def level_up!
    player.update_attribute :free_souls, player.free_souls + 1
    self.level += 1
    self.health += HEALTH_PER_LEVEL_UP
  end

  def die!
    self.health = 0
    self.alive = false

    # Refund the soul to its owner
    player.update_attribute :free_souls, player.free_souls + 1
  end

  private

  def move_randomly!
    new_x_coord = x + (1 - rand(3))
    new_y_coord = y + (1 - rand(3))

    move_to new_x_coord, new_y_coord
  end

  def swarm_nearest_faction!
    faction_souls_nearby = world.souls.where(
      alive: true,
      role: role,
      x: (x - VISION_RANGE)..(x + VISION_RANGE),
      y: (y - VISION_RANGE)..(y + VISION_RANGE)
    ).where.not(
      id: id,
      x: x,
      y: y
    )

    soul_to_swarm_to = faction_souls_nearby.sample
    return move_randomly! unless soul_to_swarm_to.present?

    new_x_coord = x
    new_x_coord += (1 - rand(2)) if soul_to_swarm_to.x > x
    new_x_coord -= (1 - rand(2)) if soul_to_swarm_to.x < x

    new_y_coord = y
    new_y_coord += (1 - rand(2)) if soul_to_swarm_to.y > y
    new_y_coord -= (1 - rand(2)) if soul_to_swarm_to.y < y

    move_to new_x_coord, new_y_coord
  end

  def swarm_nearest_soul!
    souls_nearby = world.souls.where(
      alive: true,
      x: (x - VISION_RANGE)..(x + VISION_RANGE),
      y: (y - VISION_RANGE)..(y + VISION_RANGE)
    ).where.not(
      id: id,
      x: x,
      y: y
    )

    soul_to_swarm_to = souls_nearby.sample
    return move_randomly! unless soul_to_swarm_to.present?

    new_x_coord = x
    new_x_coord += (1 - rand(2)) if soul_to_swarm_to.x > x
    new_x_coord -= (1 - rand(2)) if soul_to_swarm_to.x < x

    new_y_coord = y
    new_y_coord += (1 - rand(2)) if soul_to_swarm_to.y > y
    new_y_coord -= (1 - rand(2)) if soul_to_swarm_to.y < y

    move_to new_x_coord, new_y_coord
  end

  def move_to x, y
    update_attributes!({
      x: x % world.width,
      y: y % world.height
    })
  end
end
