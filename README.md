# Squazzle

...a Square Puzzle Flutter game!

## Architecture

This app implements [Didier Boelens'](https://www.didierboelens.com/2018/12/reactive-programming---streams---bloc---practical-use-cases/) approach to BLoC.
The idea is show data through widgets that react to a bloc's Stream.
In order to simplify state management, I've also implemented EventStates: 
blocs that emit a new widget's state based on an event.

![](https://raw.githubusercontent.com/GLodi/squazzle/master/gfx/screen.png)
