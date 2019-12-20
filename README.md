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
_.include( 'wProcessWatcher' );
_.include( 'wFiles' );

function subprocessStartEnd( o )
{
  console.log( '\n=Begin=' );
  console.log( 'arguments:', o.arguments );
  console.log( 'process pid:', o.process.pid );
}

function subprocessTerminationEnd( o )
{
  console.log( '\n=End=' );
  console.log( 'arguments:', o.arguments );
  console.log( 'process pid:', o.process.pid );
}

_.process.watcherEnable();

_.process.on( 'subprocessStartEnd', subprocessStartEnd )
_.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

_.process.start
({ 
  execPath : 'node -v', 
  deasync : 1 
});

_.process.off( 'subprocessStartEnd', subprocessStartEnd )
_.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

_.process.watcherDisable();

_.process.start
({ 
  execPath : 'node -v', 
  deasync : 1 
});


/* Output:

=Begin=
arguments: [ 'cmd',
  [ '/c', 'node "-v"' ],
  [Object: null prototype] {
    stdio: 'pipe',
    detached: false,
    cwd: 'D:\\work\\wProcessWatcher',
    windowsHide: true,
    windowsVerbatimArguments: true } ]
process pid: 7536
v10.17.0

=End=
arguments: [ 'cmd',
  [ '/c', 'node "-v"' ],
  [Object: null prototype] {
    stdio: 'pipe',
    detached: false,
    cwd: 'D:\\work\\wProcessWatcher',
    windowsHide: true,
    windowsVerbatimArguments: true } ]
process pid: 7536
 > node "-v"
v10.17.0
*/

```
