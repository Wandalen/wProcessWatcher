require( 'wprocesswatcher' );
let _ = wTools;

/* How to change default homedir for new child process by modifying original arguments */

var ChildProcess = require( 'child_process' );
var args = [ '-e', `"console.log( require( 'os' ).homedir() )"` ]
var options = { stdio : 'inherit', shell : true };

/* Spawn child process that will print homedir path before using process watcher */

console.log( 'Homedir before arguments patching:' );
ChildProcess.spawnSync( _.strQuote( process.argv[ 0 ] ), args, options );

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
ChildProcess.spawnSync( _.strQuote( process.argv[ 0 ] ), args, options );

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
