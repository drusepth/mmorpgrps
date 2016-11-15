class SpawnService
  def self.spawn quantity:, role:, player:, world:, attributes: {}
    return false if quantity > player.free_souls
    player.update_attribute :free_souls, player.free_souls - quantity.to_i

    player.souls.create(Array.new(quantity) {
      {
        player: player,
        role:   role,

        alive:  true,
        health: Soul::STARTING_HEALTH,
        level:  1,
        age:    1,

        world:  world,
        x:      rand(world.width),
        y:      rand(world.height),
      }.merge(attributes)
    })
  end
end