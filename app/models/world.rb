class World < ActiveRecord::Base
  has_many :players

  has_many :souls, through: :players

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

end
