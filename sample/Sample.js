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
