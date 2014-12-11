# tinyTron #

tinyTron is a multi-room tournament point tracking system built atop Shoes and Dropbox.

tinyTron consists of four different gui applications:

* **Builder** - Given a list of unique names, generates a series of four player matches and creates the tournament data structure.
* **Scorekeeper** - Point-Updating application used by tournament referees. 
* **WriteServer** - Handles updates sent by the scorekeeper clients and writes accordingly to the master tournament file.
* **Viewer** - Player client for viewing the current ranking of players and the upcoming matches in each room. 

tinyTron version 1.0 using atop of Shoes 3.2.18. 