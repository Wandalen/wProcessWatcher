( function _ProcessWatcher_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wAppBasic' );

  require( '../l5/ProcessWatcher.s' );

  var ChildProcess = require( 'child_process' );

}


var _global = _global_;
var _ = _global_.wTools;
var Self = {};

// --
// context
// --

function suiteBegin()
{
  var self = this;
  self.suitePath = _.path.pathDirTempOpen( _.path.join( __dirname, '../..' ), 'ProcessWatcher' );
  self.toolsPath = _.path.nativize( _.path.resolve( __dirname, '../../Tools.s' ) );
  self.toolsPathInclude = `var _ = require( '${ _.strEscape( self.toolsPath ) }' )\n`;
}

//

function suiteEnd()
{
  var self = this;

  _.assert( _.strHas( self.suitePath, '/ProcessWatcher-' ) )
  _.path.pathDirTempClose( self.suitePath );
}

function isRunning( pid )
{
  try
  {
    return process.kill( pid, 0 );
  }
  catch (e)
  {
    return e.code === 'EPERM'
  }
}

//

function spawn( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 1, mode : 'spawn' });
  let beginCounter = 0;
  let endCounter = 0;
  let onBeginGot,onEndGot;

  var expectedArguments =
  [
    'cmd',
    [ '/c', 'node "-v"' ],
    {
      'stdio' : 'pipe',
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true,
      'windowsVerbatimArguments' : true
    }
  ]

  let onBegin = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( onBeginGot.process, got.process );
  test.identical( onEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( onBeginGot.proces !== got.process );
  test.is( onEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function spawnSync( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 0, sync : 1, mode : 'spawn' });
  let beginCounter = 0;
  let endCounter = 0;

  var expectedArguments =
  [
    'node',
    [ '-v' ],
    {
      'stdio' : 'pipe',
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]

  let onBegin = ( o ) =>
  {
    test.identical( o.process, null )
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.identical( o.process, null )
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function fork( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 1, mode : 'fork' });
  let beginCounter = 0;
  let endCounter = 0;
  let onBeginGot,onEndGot;

  var expectedArguments =
  [
    '-v',
    [],
    {
      'silent' : false,
      'env' : null,
      'stdio' : 'pipe',
      'execArgv' : [],
      'cwd' : process.cwd()
    }
  ]

  let onBegin = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( '-v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( '-v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( onBeginGot.process, got.process );
  test.identical( onEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( '-v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( onBeginGot.proces !== got.process );
  test.is( onEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function exec( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 1, mode : 'exec' });
  let beginCounter = 0;
  let endCounter = 0;
  let onBeginGot,onEndGot;

  var expectedArguments =
  [
    'node "-v"',
    { 'env' : null, 'cwd' : process.cwd(), 'shell' : true },
    undefined
  ]

  let onBegin = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( onBeginGot.process, got.process );
  test.identical( onEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( onBeginGot.proces !== got.process );
  test.is( onEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function execFile( test )
{
  let self = this;

  let start = function execFile( exec, args )
  {
    let ready = new _.Consequence();
    var childProcess = ChildProcess.execFile( exec, args );
    var result = { process : childProcess };
    childProcess.on( 'close', ( exitCode, exitSignal ) =>
    {
      result.exitCode = exitCode;
      result.exitSignal = exitSignal;
      ready.take( result )
    })
    childProcess.on( 'error', ( err ) => ready.error( err ) )
    return ready.deasync();
  }
  let beginCounter = 0;
  let endCounter = 0;
  let onBeginGot,onEndGot;

  var expectedArguments =
  [
    'node',
    [ '-v' ]
  ]

  let onBegin = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.identical( onBeginGot.process, got.process );
  test.identical( onEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.is( onBeginGot.proces !== got.process );
  test.is( onEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

}

//

function execSync( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 0, sync : 1, mode : 'exec' });
  let beginCounter = 0;
  let endCounter = 0;

  var expectedArguments =
  [
    'node "-v"',
    { 'env' : null, 'cwd' : process.cwd(), 'shell' : true },
    undefined
  ]

  let onBegin = ( o ) =>
  {
    test.identical( o.process, null );
    test.identical( o.arguments, expectedArguments );
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.identical( o.process, null );
    test.is( _.bufferRawIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function execFileSync( test )
{
  let self = this;

  let start = function execFileSync( exec, args )
  {
    var result = Object.create( null );
    try
    {
      result.process = ChildProcess.execFileSync( exec, args );
      result.exitCode = 0;
    }
    catch ( err )
    {
      result.process = err;
      result.exitCode = result.process.status;
    }
    return result;
  }
  let beginCounter = 0;
  let endCounter = 0;
  let onBeginGot,onEndGot;

  var expectedArguments =
  [
    'node',
    [ '-v' ]
  ]

  let onBegin = ( o ) =>
  {
    test.identical( o.process, null );
    test.identical( o.arguments, expectedArguments );
    onBeginGot = o;
    beginCounter++
  }
  let onEnd = ( o ) =>
  {
    test.identical( o.process, null );
    test.is( _.bufferNodeIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    onEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  var watcher = _.process.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.identical( onBeginGot.process, null );
  test.identical( onEndGot.process, null );
  test.identical( onEndGot.returned, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  watcher.unwatch();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.is( onBeginGot.proces !== got.process );
  test.is( onEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

// function killZombieProcess( test )
// {
//   let self = this;
//   let childProcess = null;

//   function onBegin( child )
//   {
//     childProcess = child;
//   }

//   let watcher = new _.process.ProcessWatcher();
//   watcher.watchMaking({ onBegin });

//   _.process.start
//   ({
//     execPath : 'node -e "setTimeout( () => {}, 100000000 )"',
//     throwingExitCode : 0
//   });

//   let ready = _.timeOut( 3000 );

//   ready.then( () =>
//   {
//     test.is( childProcess instanceof ChildProcess.ChildProcess );
//     test.is( self.isRunning( childProcess.pid ) );
//     childProcess.kill();
//     test.is( !self.isRunning( childProcess.pid ) );
//     return null;
//   })

//   return ready;
// }

// killZombieProcess.timeOut = 5000;

// --
// test
// --

var Proto =
{

  name : 'Tools.base.l5.ProcessWatcher',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,

  context :
  {
    suitePath : null,
    toolsPath : null,
    toolsPathInclude : null,
    isRunning
  },

  tests :
  {
    spawn,
    spawnSync,
    fork,
    exec,
    execFile,
    execSync,
    execFileSync
    // killZombieProcess
  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
