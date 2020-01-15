( function _ProcessWatcher_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  require( '../l5/ProcessWatcher.s' );
  
  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wAppBasic' );

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
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
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
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( subprocessStartEndGot.process, got.process );
  test.identical( subprocessTerminationEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( subprocessStartEndGot.proces !== got.process );
  test.is( subprocessTerminationEndGot.proces !== got.process );
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
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
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
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.identical( o.process, null )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.identical( o.process, null )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
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
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
  var expectedArguments = 
  [
    '-v',
    [],
    {
      'silent' : false,
      'env' : null,
      'stdio' : 'pipe',
      'execArgv' : process.execArgv,
      'cwd' : process.cwd()
    }
  ]
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( '-v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( '-v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( subprocessStartEndGot.process, got.process );
  test.identical( subprocessTerminationEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( '-v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( subprocessStartEndGot.proces !== got.process );
  test.is( subprocessTerminationEndGot.proces !== got.process );
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
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
  var expectedArguments = 
  [
    'node "-v"',
    { 'env' : null, 'cwd' : process.cwd(), 'shell' : true },
    undefined
  ]
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.identical( subprocessStartEndGot.process, got.process );
  test.identical( subprocessTerminationEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.is( subprocessStartEndGot.proces !== got.process );
  test.is( subprocessTerminationEndGot.proces !== got.process );
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
    ready.deasyncWait();
    return ready.sync();
  }
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
  var expectedArguments = 
  [
    'node',
    [ '-v' ]
  ]
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.is( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.identical( subprocessStartEndGot.process, got.process );
  test.identical( subprocessTerminationEndGot.process, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.is( subprocessStartEndGot.proces !== got.process );
  test.is( subprocessTerminationEndGot.proces !== got.process );
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
    { 'env' : null, 'cwd' : process.cwd() },
  ]
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.identical( o.process, null );
    test.identical( o.arguments, expectedArguments );
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.identical( o.process, null );
    test.is( _.bufferAnyIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
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
  let subprocessStartEndGot,subprocessTerminationEndGot;
  
  var expectedArguments = 
  [
    'node',
    [ '-v' ]
  ]
  
  let subprocessStartEnd = ( o ) => 
  { 
    test.identical( o.process, null );
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    test.identical( o.process, null );
    test.is( _.bufferNodeIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.identical( subprocessStartEndGot.process, null );
  test.identical( subprocessTerminationEndGot.process, null );
  test.identical( subprocessTerminationEndGot.returned, got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  _.process.watcherDisable();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  test.is( !_.routineIs( ChildProcess._spawnSync ) );
  test.is( !_.routineIs( ChildProcess._execSync ) );
  test.is( !_.routineIs( ChildProcess._execFileSync ) );

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.is( subprocessStartEndGot.proces !== got.process );
  test.is( subprocessTerminationEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function watcherDisable( test )
{
  let subprocessStartBegin = () => {}
  
  test.case = 'disabled try to disable again'
  test.mustNotThrowError( () => _.process.watcherDisable() );
  
  test.case = 'disable with handler registered'
  _.process.watcherEnable();
  test.is( _.process.watcherIsEnabled() )
  _.process.on( 'subprocessStartBegin', subprocessStartBegin );
  test.shouldThrowErrorSync( () => _.process.watcherDisable() );
  test.is( _.process.watcherIsEnabled() )
  
  test.case = 'unregister handler then disable watcher'
  _.process.off( 'subprocessStartBegin', subprocessStartBegin );
  _.process.watcherDisable()
  test.is( !_.process.watcherIsEnabled() )
  
}

//

function patchHomeDir( test )
{
  let self = this;
  
  let start = _.process.starter({ mode : 'spawn', outputCollecting : 1 });
  let homedirPath = _.path.nativize( '/D/tmp.tmp' );
  
  let onPatch = ( o ) => 
  {  
    o.arguments[ 2 ].env = Object.create( null );
    if( process.platform == 'win32' )
    o.arguments[ 2 ].env[ 'USERPROFILE' ] = homedirPath
    else
    o.arguments[ 2 ].env[ 'HOME' ] = homedirPath
  }
  
  _.process.watcherEnable();
  
  _.process.on( 'subprocessStartBegin', onPatch )
  
  
  return start( `node -e "console.log( require('os').homedir() )"` )
  .then( ( got ) => 
  {
    test.identical( got.exitCode, 0 );
    test.is( _.strHas( got.output, homedirPath ) );
    _.process.off( 'subprocessStartBegin', onPatch )
    _.process.watcherDisable();
    return null;
  })
}

//

function spawnError( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 1, mode : 'spawn' });
  let startBegin = 0;
  let startEnd = 0;
  let endCounter = 0;
  
  var expectedArguments = 
  [
    'nnooddee',
    [],
    {
      'stdio' : 'pipe',
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]
  
  let subprocessStartBegin = ( o ) =>
  {
    test.identical( o.process, null );
    test.identical( o.arguments, expectedArguments );
    startBegin++
  }
  
  let subprocessStartEnd = ( o ) => 
  { 
    startEnd++
  }
  let subprocessTerminationEnd = ( o ) => 
  { 
    endCounter++
  }

  test.identical( startBegin, 0 );
  test.identical( startEnd, 0 );
  test.identical( endCounter, 0 );
  
  _.process.watcherEnable();
  
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  test.is( _.routineIs( ChildProcess._spawnSync ) );
  test.is( _.routineIs( ChildProcess._execFileSync ) );
  
  _.process.on( 'subprocessStartBegin', subprocessStartBegin )
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )
  
  let ready = test.shouldThrowErrorAsync( start( 'nnooddee' ) );
  
  ready.then( ( got ) => 
  {
    
    test.notIdentical( got.exitCode, 0 );
    
    test.identical( startBegin, 1 );
    test.identical( startEnd, 0 );
    test.identical( endCounter, 0 );
    
    _.process.off( 'subprocessStartBegin', subprocessStartBegin )
    _.process.off( 'subprocessStartEnd', subprocessStartEnd )
    _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )
    
    _.process.watcherDisable();
    
    test.is( !_.routineIs( ChildProcess._spawn ) );
    test.is( !_.routineIs( ChildProcess._execFile ) );
    test.is( !_.routineIs( ChildProcess._fork ) );
    test.is( !_.routineIs( ChildProcess._spawnSync ) );
    test.is( !_.routineIs( ChildProcess._execSync ) );
    test.is( !_.routineIs( ChildProcess._execFileSync ) );
    
    return null;
  })
  
  return ready;
}

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
  processWatching : 0,

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
    
    execFileSync,
    
    watcherDisable,
    
    patchHomeDir,
    
    spawnError
  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
