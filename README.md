Card Board
=========

Card Board is a general game system for playing card games over a network. 

Features
----
  - LAN play via RTMFP (following Tom Krcha's [post] [2])
  - Supports almost all of the functionality necessary for typical card games
  - For smooth, generic, realtime play: Chips, Shuffling, Card counters, Card arranging functions
  - Includes demo code for semi-automatic functionality that understands the rules of poker: handling bets, understanding betting turns, analyzing hand strength (via hoen's [PokerFace])

History
----
Card Board is the product of [my dissertation on card game systems] [1] where I study the design concept of **flexibility** in game systems. (Video snippet [here] [3].) Card Board is used to demonstrate how a game system can be **dumb, but useful**. Additionally, with its *semi-automatic* components, I explore how to add intelligence to the system without sacrificing the freedom to play however you want. When I finished my user evaluations, I believed that Card Board's general features were mature enough to be released to the public. Its semi-automatic components were an interesting design exploration, but was more useful as a demonstration of what might be possible in the future. So, I cleaned and refactored the code (along with major performance optimizations) for public release, preparing the general game system to be actively developed and leaving the rest as demo code.

Purpose
----
Card Board is offered as open-source as a robust basic card game engine for real-time play. I look forward to maintaining it as a game system that can be used for general tabletop games.

Wishlist
----
I expect active development to move along at a leisurely pace. Here are my priorities for new features:
* Improved card handling: Dealing cards to multiple players in a natural way (I am considering having the user select card and with a shake, have them divided into even piles of 3, 4, etc...)
* Improved customization: allow players to add their own card artwork, allow players to configure areas in-game
* *Long-term*: WAN Networking, play Card Board with friends beyond the Local Area Network
* *Long-term*: After Card Board's basic platform of simulating card-play is more mature, revisit the concept of semi-automatic components such as the BetTracker, Card evaluator, etc... 

Instructions
----
You can try Card Board immediately. Download the swf file from the bin directory and open it with your favorite Flash-enable web-browser. Click on **Start Server** if you just want to see how the interface works.
**Client-as-Server Instructions:**
* Type a UserId (no Password or Server necessary for LAN play)
* Choose a color for your cursor
* Click Start Server

**Client Instructions:**
* Must be on the same Local Network. This release only supports connections over the local area network.
* Type a UserId (no Password or Server necessary for LAN play)
* Choose a color for your cursor
* Type in the same Gameroom as the Server
* Type in the UserId of the Server
* Click Connect to Server  

**To Play**
* Double-click to flip a card. Also, press "F" or use the menu to flip all cards up or down.
* Press "R" to rotate a card. (This is an incomplete feature: edge-detection behaves as if the card was not rotated).
* Right - click for menu. 
 * It matters where you right - mouse clicked. That is where cards will go if you shuffle or view an area.
 * The order of cards by X, then Y position is preserved when spreading/stacking cards via the menu.
* Viewing a private area:
 * Right click on a brown area and click Toggle View to see cards in that area. 

License
----

BSD 3-Clause License


[1]:https://digital.lib.washington.edu/researchworks/handle/1773/25132
[PokerFace]:https://github.com/houen/PokerFace
[2]:http://tomkrcha.com/?p=1803
[3]:https://www.youtube.com/watch?v=KZy8fBEKoh4


