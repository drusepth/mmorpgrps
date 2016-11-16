MMORPGRPS
=========

A Massively Multiplayer Online Role Playing Game of Rock, Paper, Scissors

Played over IRC with a linguistic user interface.

* [View the live world map here](https://polar-spire-49459.herokuapp.com/world/map)
* [View the live scoreboards here](https://polar-spire-49459.herokuapp.com/world/scoreboards)

Rules of the game
-----------------

* Each player begins with 10 free souls, and can use any number of those souls to
  spawn knights of Rock, Paper, or Scissors into the world.
* Each world has height and width dimensions (default 100x100), and moving to any
  edge will wrap knights around to the opposite edge (as if the world were round!).
* The (0,0) coordinate is in the top-left of the map.
* For the time being, knights are spawned randomly within the world.
* The game ticks time forward  with every message sent over IRC, whether related
  to the game or not. During each tick, every knight ages, moves, and attacks all
  other knights owned by other players nearby.
* Rather than randomly moving around the world, knights seek out their own factions
  and travel in packs of varying sizes. When friendly factions aren't nearby, knights
  will move randomly until they find friends.
* Knights never attack their own faction, however. Scissors won't attack scissors,
  paper won't attack paper, and rock won't attack rock.
* Additionally, knights owned by the same player will not attack each other, even if
  they are of different factions (e.g. Bob's rocks won't attack his scissors).
* During each tick of the game, there is a small chance that an Evil Giant will spawn
  as a Rock Giant / Paper Giant / Scissors Giant. These giants can be attacked by
  any faction, and reward bonus souls to the player that lands the killing blow on them.
* Knights start out with 100 HP, and super-effective attacks (e.g. paper to rock) deal
  100 damage. Not-very-effective attacks (e.g. paper to scissors) deal 25 damage.
* Older knights always attack first.
* Whenever a knight dies, the player that spawned it is refunded one soul to spawn
  another knight with.
* Whenever a knight dies, the knight that killed it levels up and gains 50 health.
* Whenever a knight levels up, the player that spawned it is awarded an extra soul
  to spawn an additional knight with. The death of this additonal knight refunds a
  soul to the player like any other knight.

Future rules
------------

Soon, the following additions will be in play:

* Players will be able to choose where their knights spawn, allowing for more tactical
  spawns, better faction strongholds, and scoreboard-led assassination missions.

And, of course, suggestions are welcome!

Scoring
-------

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

Running the game
----------------

To set up your own instance and world for the game, just check this repo out, create a
database with

```
rake db:create db:migrate
```

and then connect an IRC client to your favorite network and channel with

```
rake irc:play
```

You will need to customize the network/channel (and potentially nick) in `lib/tasks/irc_client.rake`. By default, this will create a new world for you. You can reconnect to existing worlds by specifying their ID
as a parameter, e.g.
```
rake irc:play 4
```

To run the web server, simply run:

```
rails server
```

and visit http://localhost:3000/ in your browser.

There is a world map available at `localhost:3000/world/map`, and several scoreboards available at
`localhost:3000/world/scoreboards`. In order for these pages to be available to others on your network,
you can run the server bound to `0.0.0.0` instead, with

```
rails server -b 0.0.0.0
```

Happy RPS-ing!
