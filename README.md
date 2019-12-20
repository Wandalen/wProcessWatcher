# wProcessWatcher [![Build Status](https://travis-ci.org/Wandalen/wProcessWatcher.svg?branch=master)](https://travis-ci.org/Wandalen/wProcessWatcher)

Collection of routines to watch child process. Register/unregister handlers for child process start/close. Use the module to monitor creation of child processes and obtain information about command,arguments and options used to create the child process.

### Try out
```
npm install
node sample/Sample.s
```

##### Example

```javascript
var _ = require( 'wTools' );
_.include( 'wProcessWatcher' )

var ChildProcess = require( 'child_process' )
var args = [ '-e', `"console.log( require( 'os' ).homedir() )"` ]
var options = { stdio : 'inherit', shell : true };

console.log( 'Homedir before arguments patching:' );
ChildProcess.spawnSync( 'node', args, options, );

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

console.log( '\nHomedir after arguments patching:' );
ChildProcess.spawnSync( 'node', args, options );

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
