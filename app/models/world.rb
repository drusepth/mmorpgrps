class World < ActiveRecord::Base
  has_many :players
  has_many :souls, through: :players

  GIANT_SPAWN_RATE = 500 # One in X chance to spawn a giant per tick
  DRAGON_SPAWN_RATE = 750 # One in X chance to spawn a dragon per tick

  def stats
    {
      'Living souls'     => souls.where(alive: true).count,
      'Dead souls'       => souls.where(alive: false).count,
      'Free souls'       => players.sum(:free_souls),
      'Players'          => players.count,
      'Rocks'            => souls.where(alive: true, role: 'rock').count,
      'Papers'           => souls.where(alive: true, role: 'paper').count,
      'Scissors'         => souls.where(alive: true, role: 'scissor').count,
      'Giants'           => souls.where(alive: true, role: ['rock giant', 'paper giant', 'scissors giant']).count,
      'Average soul age' => souls.average(:age).to_i
    }
  end

  def human_readable_stats
    stats.map { |item, quantity| "#{quantity} #{item.downcase}" }.to_sentence
  end

  def tick
    messages_to_report = []

    souls.where(alive: true).each do |soul|
      soul.age!
      soul.move!

      puts "doing stuff with #{soul.id} (#{soul.role}) at #{soul.x}, #{soul.y}"

      other_souls_here = souls.where(alive: true, x: soul.x, y: soul.y)
        .where.not(player: soul.player, role: soul.role)

      other_souls_here.each do |other_soul|
        puts "attacking other soul #{other_soul.id} at #{soul.x}, #{soul.y}"
        soul.attack! other_soul

        messages_to_concatenate = [
          "#{soul.player.name}'s L#{soul.level} #{soul.role} at (#{soul.x}, #{soul.y}) attacked #{other_soul.player.name}'s L#{other_soul.level} #{other_soul.role} at (#{other_soul.x}, #{other_soul.y})."
        ]
        if soul.alive
          messages_to_concatenate << "#{soul.player.name}'s #{soul.role} has #{soul.health} health remaining."
        else
          messages_to_concatenate << "#{soul.player.name}'s L#{soul.level} #{soul.role} has died!"
        end

        if other_soul.alive
          messages_to_concatenate << "#{other_soul.player.name}'s #{other_soul.role} has #{other_soul.health} health remaining."
        else
          messages_to_concatenate << "#{other_soul.player.name}'s L#{other_soul.level} #{other_soul.role} has died!"
        end

        messages_to_report << messages_to_concatenate.join(' ')
        other_soul.save if other_soul.changed?
      end
    end

    ActiveRecord::Base.transaction do
      souls.each { |soul| soul.save if soul.changed? }
    end

    # Maybe spawn a boss or something
    if rand(GIANT_SPAWN_RATE) == 0
      giant = SpawnService.spawn(quantity: 1,
        role: %w(rock paper scissors).sample + ' giant',
        player: $world.players.find_or_create_by(name: 'Evil Bad Guy'),
        world: $world,
        attributes: {
          level:       5,
          health:      Soul::STARTING_HEALTH * 3,
          soul_bounty: 5
        }
      ).first

      messages_to_report << "An evil #{giant.role} has spawned at (#{giant.x}, #{giant.y})! Defeat it for #{giant.soul_bounty} bonus souls!"
    end

    if rand(DRAGON_SPAWN_RATE) == 0
      dragon = SpawnService.spawn(quantity: 1,
        role: %w(rock paper scissors).sample + ' dragon',
        player: $world.players.find_or_create_by(name: 'Evil Bad Guy'),
        world: $world,
        attributes: {
          level:       7,
          health:      Soul::STARTING_HEALTH * 5,
          soul_bounty: 50
        }
      ).first

      messages_to_report << "An evil #{dragon.role} has spawned at (#{dragon.x}, #{dragon.y})! Defeat it for #{dragon.soul_bounty} bonus souls!"
    end

    # Return any world events to report
    messages_to_report
  end
end
