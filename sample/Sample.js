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
