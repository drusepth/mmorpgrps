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
        'Souls':   Soul.count,
        'Players': Player.count
      }
    end

    def human_friendly_world_stats
      world_stats.map { |item, quantity| "#{quantity} #{item}" }.to_sentence
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
              puts "Spawning #{role} #{i + 1}"
              binding.pry

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
            end

            puts "Done!"

            m.reply "Your #{quantity} #{role} have been spawned. The world now contains #{human_friendly_world_stats}."
          end
        end
      end

      on :message, /world/ do |m|
        m.reply "The world contains #{human_friendly_world_stats}."
      end

      on :message, /.*/ do |m|
          # Tick world forward
          # TODO: Move game tick logic into WorldTickService
          # Soul.all.each do |soul|
          #   soul.age!
          #   soul.move!
          # end
        end
      end

      bot.start
    end
  end