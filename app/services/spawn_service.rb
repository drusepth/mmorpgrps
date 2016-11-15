class SpawnService
  def self.spawn quantity:, role:, player:, world:
    return false if quantity > player.free_souls

    player.souls.create(Array.new(quantity) {
      {
        player: player,
        role:   role,

        alive:  true,
        health: Soul::STARTING_HEALTH,
        level:  1,
        age:    1,

        x:      rand(world.width),
        y:      rand(world.height),
      }
    })

    player.update_attribute :free_souls, player.free_souls - quantity.to_i
  end
end