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
