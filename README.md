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
  console.log( 'New child process with pid:', o.process.pid );
}

_.process.watcherEnable();
_.process.on( 'subprocessStartEnd', subprocessStartEnd )

_.process.start
({ 
  execPath : 'node -v',
  outputPiping : 0,
  inputMirroring : 0,
  deasync : 1 
});

_.process.off( 'subprocessStartEnd', subprocessStartEnd )
_.process.watcherDisable();

/* 
Output:

New child process with pid: 2536

*/
```
