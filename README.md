# Squazzle

...a Square Puzzle Flutter game!

![](https://raw.githubusercontent.com/GLodi/master/gfx/screen.jpg)

## Architecture

This app implements [Didier Boelens'](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/) approach to BLoC.
The idea is show data through widgets that react to a bloc's Stream.
In order to simplify state management, I've also implemented EventStates: 
blocs that emit a new widget's state based on an event.

