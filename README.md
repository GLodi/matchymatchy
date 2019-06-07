# Squazzle

...a Square Puzzle Flutter game! The goal is to reproduce the top right pattern
on the 9 center squares with as few moves as possible.

STILL IN DEVELOPMENT 

<div align="center">
	<img src="https://raw.githubusercontent.com/GLodi/squazzle/master/gfx/screen.png" width="256">
</div>

## Architecture

This app implements [Didier Boelens'](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/) approach to BLoC.
The idea is to show data through widgets that react to a bloc's Stream.
In order to simplify state management, I've also implemented EventStates: 
blocs that emit a new widget's state based on an event.

## Features

  - Singleplayer
 The app comes with a sql db of 500 combinations of target fields + game fields. A random 
 combination is chosen at random.
 
  - Multiplayer
Multiplayer is handled by Firebase. You can find the Firebase project under the directory functions. 
Still under development, but you can copy it into your Firebase project and give it a try.
