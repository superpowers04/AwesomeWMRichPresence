# AwesomeWMRichPresence
A really clunky way of doing discord rich presence
This uses a lot of bad code and some really bad programming practices but it works for me so :shrug:
Check the haxe branch for the haxe code

# Requirements
* Luvit installed and accessible from your $PATH
* XTerm by default
* AwesomeWM

# Installation
* Run `git clone https://github.com/superpowers04/AwesomeWMRichPresence` inside of your AwesomeWM config
	(Running `cat ~/.config/awesome/AwesomeWMRichPresence/DRP.lua` should print the contents of the script in your terminal, the script expects to be installed there)
* Add `local DRP = require('AwesomeWMRichPresence.DRP')`
* Add `DRP.initDRP()` Somewhere, like at the bottom of your rc.lua. DRP will NOT work until you do this
* Add `DRP.toggleDRP` to your menu or something for a toggle, alternatively just pass true 
