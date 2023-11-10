# Overview


This game is a coop PvE Top-Down fighting game where the players take on increasingly difficult waves of enemies, using a variety of weapons such as spears, bows, and swords to fight their way to victory.

The controls are as follows:
W,A,S, and D: move around
Your character will automatically look at your mouse.
1,2,3, and 4 will change your item
Left click will use a weapons basic attack, or punch if you have none equipped
Right click will use a weapons alternative attack

The easiest way to start a game is to hit the host button and then the start game button

I wanted to become more knowledgeable on the up and coming engine Godot, specifically in using animation to drive gameplay. This project heavily uses animationtrees to drive gameplay, such as a charging animation calling a function to move the player forward. It also features multiplayer as another complex feature I wanted to learn more about.

{Provide a link to your YouTube demonstration.  It should be a 4-5 minute demo of the game being played and a walkthrough of the code.}

[Software Demo Video](https://youtu.be/vREekBrXbVQ)
[Part 2: Shaders](https://www.youtube.com/watch?v=H1YkE-9Xhk8)
[Part 3: Networking](https://www.youtube.com/watch?v=2VZNu8mQ1O8)
[Part 3: State Machine AI](https://www.youtube.com/watch?v=3fkzYN8VCt0)
# Development Environment

This game was developed in Godot using GDscript. No additional libraries or systems were used outside of what is included in base Godot.

# Useful Websites

{Make a list of websites that you found helpful in this project}
* [Godot Shaders]([http://url.link.goes.here](https://godotshaders.com/))
* [Godot Documentation]([http://url.link.goes.here](https://docs.godotengine.org/en/stable/index.html))


# Module 2 Changes
Three shaders have been fully implemented.
Two of them can be seen when starting the game. The first is a diamonds effect that covers the screen in darkness. The second is a psychedillic shaders effect that works as a loading screen. 
The final shader is a blinking shader that appears whenever the player takes damage.

# Module 3 Changes
The game is now properly and fully multiplayer networked.
The main menu now allows players to change which port and IP address they would like to connect to.
Network optimization techniques have been employed to reduce packets sent, making the game easier to run on poor networks.

# Module 4 Changes

Enemies spawn that will attack the players.
They can have multiple different weapons and attack styles/preferences
Enemies integrate with existing animation systems and codebases for a flexible, modular system.

# Future Work

This project is finished!