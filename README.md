# matchymatchy

...a matching colors Flutter game! 

The goal is to reproduce the top right pattern
on the 9 center squares with as few moves as possible.

STILL IN DEVELOPMENT 

<div align="center">
	<img src="https://raw.githubusercontent.com/GLodi/matchymatchy/master/gfx/newgif.gif" width="256">
</div>

Fun fact: this app was entirely developed on [emacs](https://giuliolodi.dev/2019/05/06/flutter-on-spacemacs)!

## Architecture

This app implements [Didier Boelens'](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/) approach to BLoC.
The idea is to show data through widgets that react to a bloc's Stream.
In order to simplify state management, I've also implemented EventStates: 
blocs that emit a new widget's state based on an event.

## Multiplayer

Multiplayer is handled by Firebase. A Firestore database stores all matches, queue and users
information and all endpoints are Firebase Functions written in Typescript 
(project under directory **functions**).

 - Queue

When a player looks for a new match, he's put in a FIFO queue and joins a match as soon as an opponent
is found. A common target is chosen for them and whoever reaches the goal with the fewest amount of 
moves wins.

 - Reconnection
 
Players can leave a match at any time and reconnect later. Active matches are stored on the device
thanks to sqflite.

 - Forfeit

Players can forfeit a match. This immediately triggers a win condition for the opponent.

 - Move/Win/Challenge notification
 
Notifications are handled by Firebase Cloud Messaging. Every time a player is challenged, or an opponent plays a move, both players are notified.


If you want to use the online component, you can create a new Firebase project, 
create your own google-services.json and put it under android/app.

## Singleplayer

The app comes with a sqflite db of 500 combinations of target fields + game fields. A random 
combination is chosen.
