# wProcessWatcher [![Build Status](https://travis-ci.org/Wandalen/wProcessWatcher.svg?branch=master)](https://travis-ci.org/Wandalen/wProcessWatcher)

Collection of routines for child process monitoring. Allows to keep track of creation, spawn and termination of a child process via events. Get information about command, arguments and options used to create a child process. Modify command, arguments or options on the creation stage. Access instance of ChildProcess on spawn and termination stages.


### Try out
```
npm install
node sample/Sample.s
```

##### Example

```javascript
var _ = require( 'wTools' );
_.include( 'wProcessWatcher' )

/* How to change default homedir for new child process by modifying original arguments */

var ChildProcess = require( 'child_process' );
var args = [ '-e', `"console.log( require( 'os' ).homedir() )"` ]
var options = { stdio : 'inherit', shell : true };

/* Spawn child process that will print homedir path before using process watcher */

console.log( 'Homedir before arguments patching:' );
ChildProcess.spawnSync( 'node', args, options, );

/* Enable process watcher and register callback that will be executed before spawning the child process */

function subprocessStartBegin( o )
{ 
  o.arguments[ 2 ].env = 
  {
    'USERPROFILE' : 'C:\\some\\path',
    'HOME' : '/some/path'
  }
}

_.process.watcherEnable();
_.process.on( 'subprocessStartBegin', subprocessStartBegin )

/* Spawn child process that will print new homedir path */

console.log( '\nHomedir after arguments patching:' );
ChildProcess.spawnSync( 'node', args, options );

/* Deregister callback and disable process watcher */

_.process.off( 'subprocessStartBegin', subprocessStartBegin )
_.process.watcherDisable();

/* 
Output:
Homedir before arguments patching:
C:\Users\fov

Homedir after arguments patching:
C:\some\path

*/
```
