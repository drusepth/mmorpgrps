== MMORPGRPS

A Massively Multiplayer Online Role Playing Game of Rock, Paper, Scissors

Played over IRC with a linguistic user interface.

== Rules of the game

* Each player begins with 10 free souls, and can use any number of those souls to
  spawn knights of Rock, Paper, or Scissors into the world.
* For the time being, knights are spawned randomly within the bounding box of the
  outer-most knights of the world.
* The game ticks time forward every with every message sent over IRC, whether related
  to the game or not. During each tick, every knight ages, moves randomly, and attacks
  all other knights owned by other players nearby.
* Knights never attack their own faction, however. Scissors won't attack scissors,
  paper won't attack paper, and rock won't attack rock.
* Knights start out with 100 HP, and super-effective attacks (e.g. paper to rock) deal
  100 damage. Not-very-effective attacks (e.g. paper to scissors) deal 25 damage.
* Older knights attack first.
* Whenever a knight dies, the player that spawned it is refunded one soul to spawn
  another knight with.
* Whenever a knight dies, the knight that killed it levels up and gains 50 health.

== Future rules

Soon, the following additions will be in play:

* Players will be able to choose where their knights spawn, allowing for more tactical
  spawns, better faction strongholds, and scoreboard-led assassination missions.
* Rather than randomly moving around the world, knights will seek out their own factions
  and travel in packs of varying sizes.

And, of course, suggestions are welcome

== Scoring

Currently, the following scoreboards are available to compete on:

* Oldest knight: the oldest living knights of the world (and their locations) are
  displayed. To get onto this scoreboard, don't die!
* Highest level: knights level up whenever they kill an enemy knight. To get onto this
  scoreboard, pick your race as wisely as you pick your battles!
* Largest faction: the largest faction (rock, paper, scissors) by numbers is displayed
  here. Use this scoreboard to decide whether you want to join the crowd, fight for the
  underdog, or make a third party relevant.

More scoreboards are in the works to enable players to play how they want to play. Future
scoreboards include "most kills", "distance traveled", "battles fought", and more.

Soon, scoreboards will be available online as well.

== Running the game

To set up your own instance and world for the game, just check this repo out, create a
database with

```
rake db:create db:migrate
```

and then connect an IRC client to your favorite network and channel with

```
rake irc:play
```

You will need to customize the network/channel (and potentially nick) in lib/tasks/irc_client.rake

Soon there will also be a web-based interface as well, with maps, scoreboards, and other information.
To access it, you'll just need to run the server locally with

```
rails server
```

and visit http://localhost:3000/ in your browser.
