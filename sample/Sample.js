var _ = require( '..' )
_.include( 'wAppBasic' )
_.include( 'wFiles' )

function onBegin( o )
{
  console.log( '\n=Begin=' );
  console.log( 'arguments:', o.arguments );
  console.log( 'process pid:', o.process.pid );
}

function onEnd( o )
{
  console.log( '\n=End=' );
  console.log( 'arguments:', o.arguments );
  console.log( 'process pid:', o.process.pid );
}

var watcher = _.process.watchMaking({ onBegin, onEnd })

_.process.start
({ 
  execPath : 'node -v', 
  deasync : 1 
});

watcher.unwatch();

_.process.start
({ 
  execPath : 'node -v', 
  deasync : 1 
});
