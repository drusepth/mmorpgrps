namespace :irc do
  desc "Create a world"
  task :play => :environment do
    require 'cinch'

    config = {
      network:  'irc.amazdong.com',
      channel:  '#test',
      nick:     'RPSGM'
    }

    # TODO: Define these elsewhere
    LUI_SPAWN_REGEX = /spawn (\d+|a)? ?(rock|paper|scissor)s?/

    def world_stats
      {
        'Souls':    Soul.count,
        'Players':  Player.count,
        'Rocks':    Soul.where(role: 'rock').count,
        'Papers':   Soul.where(role: 'paper').count,
        'Scissors': Soul.where(role: 'scissor').count
      }
    end

    def human_friendly_world_stats
      world_stats.map { |item, quantity| "#{quantity} #{item.downcase}" }.to_sentence
    end

    bot = Cinch::Bot.new do
      configure do |c|
        c.server   = config[:network]
        c.channels = ['#aw', config[:channel]]
        c.nick     = config[:nick]
      end

      # TODO: Put all this logic in some SpawnerService and just pass raw text in

      on :message, LUI_SPAWN_REGEX do |m|
        player = Player.find_or_initialize_by(name: m.user.nick)

        m.message.scan(LUI_SPAWN_REGEX) do |quantity, role|
          if quantity.to_i > player.souls
            m.reply "#{player.name}: You only have #{player.souls} souls to spawn with."
          else
            puts "Spawning #{quantity} #{role}"

            quantity.to_i.times do |i|
              Soul.create({
                player: player,
                role:   role,

                alive:  true,
                health: Soul::STARTING_HEALTH,
                level:  1,
                age:    1,

                x:      rand(Soul.maximum :x) - rand(Soul.maximum :x),
                y:      rand(Soul.maximum :y) - rand(Soul.maximum :y),
              })
              player.update_attribute :souls, player.souls - 1
            end

            m.reply "Your #{quantity} #{role} have been spawned. The world now contains #{human_friendly_world_stats}."
          end
        end
      end

      on :message, /help/ do |m|
        m.reply([
          "Welcome to the war-torn world of rock, paper, scissors!",
          "Every time someone says something on IRC, time ticks forward. Rocks kill scissors, scissors kill paper, and paper kills rock.",
          "Spawn your knights by telling me 'spawn 3 rocks' or 'span 1 scissors' and regain the land for your faction!"
        ].join ' ')
      end

      on :message, /world/ do |m|
        m.reply "The world contains #{human_friendly_world_stats}."
      end

      on :message, /souls?/ do |m|
        player = Player.find_or_initialize_by(name: m.user.nick)
        m.reply "#{m.user.nick}: You have #{player.souls} soul(s) remaining. You can use them to spawn knights of Rock, Paper, or Scissors into the world. Just say something like 'spawn 5 rocks' or 'spawn 1 scissors'."
      end

      on :message, /oldest/ do |m|
        soul = Soul.where(alive: true).order('age DESC').first
        m.reply "The oldest living soul in this world is a #{soul.role.upcase} spawned by #{soul.player.name}. That #{soul.role} has #{soul.health} health and is located at (#{soul.x}, #{soul.y})."
      end

      on :message, /.*/ do |m|
          # Tick world forward
          # TODO: Move game tick logic into WorldTickService
          Soul.where(alive: true).each do |soul|
            soul.age!
            soul.move!

            other_souls_here = Soul.where(alive: true, x: soul.x, y: soul.y)
            other_souls_here.each do |other_soul|
              soul.battle! other_soul
            end
          end
        end
      end

      bot.start
    end
  end