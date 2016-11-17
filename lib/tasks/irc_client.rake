namespace :play do
  desc "Create a world"
  task :irc, [:world_id] => :environment do |t, args|
    require 'cinch'

    $config = {
      network:             'irc.wobscale.website',
      channels:            [
        { name: '#rps', reporting: true  },
        { name: '#fj2',  reporting: false }
      ],
      nick:                'RPSGM',
      messages_per_second: 10,
    }

    # TODO: Define these elsewhere
    # TODO: Allow spawning at a specific location
    LUI_SPAWN_REGEX             = /spawn (\d+|a)? ?(rock|paper|scissor)s?/

    LUI_HELP_INFO_REGEX         = /help|rules/
    LUI_MAP_INFO_REGEX          = /map/
    LUI_LOCATIONS_INFO_REGEX    = /locations/
    LUI_SOURCE_CODE_INFO_REGEX  = /source/
    LUI_SOUL_COUNT_INFO_REGEX   = /souls?/
    LUI_MY_SOULS_INFO_REGEX     = /my stats/
    LUI_PLAYER_STATS_INFO_REGEX = /(\w+)'s stats/
    LUI_WORLD_INFO_REGEX        = /world/
    LUI_SCOREBOARDS_INFO_REGEX  = /score/

    LUI_OLDEST_SCOREBOARD_REGEX = /oldest/
    LUI_LEVEL_SCOREBOARD_REGEX  = /level|kills?|strongest/

    GAME_TICK_REGEX             = /.*/

    if args[:world_id]
      puts "Loading world #{args[:world_id]}..."
      $world = World.find(args[:world_id])
    else
      puts "Creating new world..."
      $world = World.create(height: 100, width: 100)
    end

    def report m, message
      message = Format(:pink, message)

      reporting_channels = $config[:channels].select { |c| c[:reporting] }.map { |c| c[:name] }
      m.bot.channels.select { |channel| reporting_channels.include? channel.name }.each do |c|
        c.send(message)
      end
    end

    bot = Cinch::Bot.new do
      configure do |c|
        c.server   = $config[:network]
        c.channels = $config[:channels].map { |channel| channel[:name] }
        c.nick     = $config[:nick]
        c.messages_per_second = $config[:messages_per_second]
      end

      on :message, LUI_SPAWN_REGEX do |m|
        player = $world.players.find_or_create_by(name: m.user.nick)

        m.message.scan(LUI_SPAWN_REGEX) do |quantity, role|
          quantity = 1 if quantity.nil?
          spawned = SpawnService.spawn quantity: quantity.to_i, role: role, player: player, world: $world

          if spawned
            report m, "#{player.name}: Your #{quantity} L1 #{role}s have been spawned. You have #{player.free_souls} soul(s) remaining. The world now contains #{$world.human_readable_stats}."
          else
            report m, "#{player.name}: You only have #{player.free_souls} souls to spawn with."
          end
        end
      end

      on :message, LUI_HELP_INFO_REGEX do |m|
        report m, ([
          "Welcome to the war-torn world of rock, paper, scissors!",
          "Every time someone says something on IRC, time ticks forward. Rocks kill scissors, scissors kill paper, and paper kills rock.",
          "Spawn your knights by telling me 'spawn 3 rocks' or 'span 1 scissors' and regain the land for your faction!"
        ].join ' ')
      end

      on :message, LUI_WORLD_INFO_REGEX do |m|
        report m, "This #{$world.width}x#{$world.height} world contains #{$world.human_readable_stats}."
      end

      on :message, LUI_SOUL_COUNT_INFO_REGEX do |m|
        player = $world.players.find_or_create_by(name: m.user.nick)
        report m, "#{m.user.nick}: You have #{player.free_souls} soul(s) remaining. You can use them to spawn knights of Rock, Paper, or Scissors into the world. Just say something like 'spawn 5 rocks' or 'spawn 1 scissors'."
      end

      on :message, LUI_OLDEST_SCOREBOARD_REGEX do |m|
        soul = $world.souls.where(alive: true).order('age DESC').first
        report m, "The oldest living soul in this world is a L#{soul.level} #{soul.role.upcase} spawned by #{soul.player.name}, surviving for #{soul.age} ticks. That #{soul.role} has #{soul.health} health and is located at (#{soul.x}, #{soul.y})."
      end

      on :message, LUI_LEVEL_SCOREBOARD_REGEX do |m|
        soul = $world.souls.where(alive: true).order('level DESC').first
        report m, "The highest level living soul in this world is a #{soul.role.upcase} spawned by #{soul.player.name}. That level #{soul.level} #{soul.role} has #{soul.health} health and is located at (#{soul.x}, #{soul.y})."
      end

      on :message, LUI_MY_SOULS_INFO_REGEX do |m|
        player   = $world.players.find_or_create_by(name: m.user.nick)
        rocks    = $world.souls.where(player: player, role: 'rock', alive: true).order('level DESC')
        papers   = $world.souls.where(player: player, role: 'paper', alive: true).order('level DESC')
        scissors = $world.souls.where(player: player, role: 'scissor', alive: true).order('level DESC')
        highest  = $world.souls.where(player: player).order('level DESC').first
        oldest   = $world.souls.where(player: player).order('age DESC').first

        report m, ([
          "#{player.name}: You currently control #{rocks.count} rocks, ",
          "#{papers.count} papers, ",
          "and #{scissors.count} scissors. ",
          "Your highest level soul is an L#{highest.level} #{highest.role} with #{highest.health}HP at (#{highest.x}, #{highest.y}). ",
          "Your oldest is an L#{oldest.level} #{oldest.role}, #{oldest.health}HP, age #{oldest.age} at (#{oldest.x}, #{oldest.y})."
        ].join)
      end

      on :message, LUI_PLAYER_STATS_INFO_REGEX do |m|
        m.message.scan(LUI_PLAYER_STATS_INFO_REGEX) do |player_name|
          player   = $world.players.find_or_create_by(name: player_name.first)
          rocks    = $world.souls.where(player: player, role: 'rock', alive: true).order('level DESC')
          papers   = $world.souls.where(player: player, role: 'paper', alive: true).order('level DESC')
          scissors = $world.souls.where(player: player, role: 'scissor', alive: true).order('level DESC')
          highest  = $world.souls.where(player: player).order('level DESC').first
          oldest   = $world.souls.where(player: player).order('age DESC').first

          report m, ([
            "#{m.user.nick}: #{player_name.first} currently controls #{rocks.count} rocks, ",
            "#{papers.count} papers, ",
            "and #{scissors.count} scissors. ",
            "Their highest level soul is an L#{highest.level} #{highest.role} with #{highest.health}HP at (#{highest.x}, #{highest.y}). ",
            "Their oldest is an L#{oldest.level} #{oldest.role}, #{oldest.health}HP, age #{oldest.age} at (#{oldest.x}, #{oldest.y})."
          ].join)
        end
      end

      on :message, LUI_LOCATIONS_INFO_REGEX do |m|
        report m, "There are souls located at #{$world.souls.where(alive: true).order(:x).map { |s| "(#{s.x},#{s.y})" }.to_sentence}."
      end

      on :message, LUI_MAP_INFO_REGEX do |m|
        report m, "The world map is available here: https://polar-spire-49459.herokuapp.com/world/map"
      end

      on :message, LUI_SCOREBOARDS_INFO_REGEX do |m|
        report m, "Live scoreboards are available here: https://polar-spire-49459.herokuapp.com/world/scoreboards"
      end

      on :message, LUI_SOURCE_CODE_INFO_REGEX do |m|
        report m, "The full source code for MMORPGRPS is available at https://github.com/drusepth/mmorpgrps. This client's source code is at https://github.com/drusepth/mmorpgrps/blob/master/lib/tasks/irc_client.rake"
      end

      on :message, GAME_TICK_REGEX do |m|
        # Tick world forward
        world_messages = $world.tick

        world_messages.each { |message| report m, message }
      end
    end

    bot.start
  end
end

