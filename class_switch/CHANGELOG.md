## 0.0.1-dev.0
- Initial version of class switch with the following features:
  - Annotate a class with @ClassSwitch to generate a $switch extension method on the 
    annotated class. AnnotatedClass.$switch can then be used for switching over 
    sub-types of the annotated class like so:
      ```dart
    @ClassSwitch
    abstract class Base {}
    class A extends Base {}
    class B extends Base {}
    
    Base a = new A();
    String result = Base.$switch(a)(
        (a) => 'Given an A',
        (b) => 'Given a B',
    );
    assert result == 'Given an A';
    
    Base someBase = new B();
    result = someBase.$switch(
        (a) => 'Given an A',
        (b) => 'Given a B'
    );
    assert result == 'Given a B';
      ```
  - `@ClassSwitch(classes:[...])` instead generates a $switch 
    method accepts and instance of each class and enumerates the cases for every 
    possible combination of instance types:
      ```dart
    abstract class State {}
    class StateA extends State {}
    class StateB extends State {}
    
    abstract class Event{}
    class EventA extends Event {}    
    class EventB extends Event {}
    
    @ClassSwitch(classes:[State, Event])
    class StateEventHandler{}
    
    State state = new StateA();
    Event event = new EventB();
    String result = StateEventHandler.$switch(state, event)(
        (stateA, eventA) => 'A A',
        (stateA, eventB) => 'A B',
        (stateB, eventA) => 'A B',
        (stateB, eventB) => 'B B',
    );
    assert result == 'A B';
    
    StateEventHandler handler = new StateEventHandler();
    result = someBase.$switch(
        (a) => 'Given an A',
        (b) => 'Given a B'
    );
    assert result == 'Given a B';
      ```
  - @ClassSwitch also generates an abstract class named _${AnnotatedClassName}Switcher 
    which 
    

