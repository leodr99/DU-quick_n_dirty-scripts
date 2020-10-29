# DU-quick_n_dirty-scripts
simple door control....

you'll need the following:
1x Prog. Board
1x Detection Zone
.. doors/hatches...
.. screens

deploy the PBoard, then paste the config.json
connect the DZ to the board (make sure that the link is blue, that it starts from the DZ to the board, not the other way around.)
connect doors and screens to the PBoard (remember that there are only 10 slots available in a board).

now, go to advanced>>edit lua parameters. then activate debug.
you'll get you playerID, that you'll need to add onto the start section.
for that, just look at the PBoard, and press CRTL+L. choose unit on the left, then start() on the middle (filter section).
and on the right you'll see the lua code for that filter. this code runs when the board boots up.

now, at the very begining of the code, you'll see "local allowedUserIDs = {...}", just replace the numbers/IDs with the ones you want.
you can add, or remove, as many as you wish. the only condition, is that it has to have at least one :)

test it out. if any issues, just head onto the DU OSIN discord (the same of the slackers that made the Orbital Hud) and "ping" me, @LeoDr.


i'll sort you out, when possible. cheers.
