var _ = require( '../proto/dwtools/abase/l4/ProcessWatcher.s' )
require( 'wappbasic' )
require( 'wFiles' )

let watcher = new _.process.ProcessWatcher();

function onBegin( r )
{
  console.log( 'begin' );
}

function onEnd( r )
{
  console.log( 'end' );
}

watcher.watchMaking({ onBegin, onEnd })

_.process.start({ execPath : 'node -v', mode : 'spawn', deasync : 1 });

watcher.unwatchMaking()

_.process.start({ execPath : 'node -v', mode : 'spawn', deasync : 1 });
