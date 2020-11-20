const { Z_ASCII } = require('zlib');

( function _ProcessWatcher_test_s( )
{

'use strict';

let ChildProcess;

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );

  require( '../l5/ProcessWatcher.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcess' );

  ChildProcess = require( 'child_process' );

}


let _global = _global_;
let _ = _global_.wTools;
let _realGlobal = _global._realGlobal_;
let Self = {};

// --
// context
// --

function suiteBegin()
{
  var self = this;
  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'ProcessWatcher' );
  self.toolsPath = _.path.nativize( _.path.resolve( __dirname, '../../../wtools/Tools.s' ) );
  self.toolsPathInclude = `let _ = require( '${ _.strEscape( self.toolsPath ) }' )\n`;
}

//

function suiteEnd()
{
  var self = this;
  _.assert( _.strHas( self.suiteTempPath, '/ProcessWatcher-' ) )
  _.path.tempClose( self.suiteTempPath );
}

function assetFor( test, name )
{
  let context = this;
  let a = test.assetFor( name );

  _.assert( _.routineIs( a.program.head ) );
  _.assert( _.routineIs( a.program.body ) );

  let oprogram = a.program;
  program_body.defaults = a.program.defaults;
  a.program = _.routineUnite( a.program.head, program_body );
  return a;

  /* */

  function program_body( o )
  {
    let locals =
    {
      context : { t0 : context.t0, t1 : context.t1, t2 : context.t2, t3 : context.t3 },
      toolsPath : _.module.resolve( 'wTools' ),
    };
    o.locals = o.locals || locals;
    _.mapSupplement( o.locals, locals );
    _.mapSupplement( o.locals.context, locals.context );
    let programPath = a.path.nativize( oprogram.body.call( a, o ) );
    return programPath;
  }

}

function isRunning( pid )
{
  try
  {
    return process.kill( pid, 0 );
  }
  catch( e )
  {
    return e.code === 'EPERM'
  }
}

//

let _wasGlobal, _wasCache;
function globalNamespaceOpen( _global, name )
{
  if( _realGlobal_._globals_[ name ] )
  throw Error( 'Global namespace::name already exists!' );
  let Module = require( 'module' );
  _wasCache = Module._cache;
  _wasGlobal = _global;
  Module._cache = Object.create( null );
  _global = Object.create( _global );
  _global.__GLOBAL_NAME__ = name;
  _realGlobal_._global_ = _global;
  _realGlobal_._globals_[ name ] = _global;
}

//

function globalNamespaceClose()
{
  let Module = require( 'module' );
  Module._cache = _wasCache;
  _global_ = _wasGlobal;
}

//

function spawn( test )
{
  let self = this;

  let start = _.process.starter({ deasync : 1, mode : 'spawn' });
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    'node',
    [ '-v' ],
    {
      'stdio' : [ 'pipe', 'pipe', 'pipe' ],
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.true( subprocessStartEndGot.proces !== got.process );
  test.true( subprocessTerminationEndGot.proces !== got.process );
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
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    'node',
    [ '-v' ],
    {
      'stdio' :  [ 'pipe', 'pipe', 'pipe' ],
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

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
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

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
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    '-v',
    [],
    {
      'detached' : false,
      // 'silent' : false,
      'env' : null,
      'stdio' : [ 'pipe', 'pipe', 'pipe', 'ipc' ],
      'execArgv' : process.execArgv,
      'cwd' : process.cwd()
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( '-v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( '-v' ).sync();
  test.identical( got.exitCode, 0 );
  test.true( subprocessStartEndGot.proces !== got.process );
  test.true( subprocessTerminationEndGot.proces !== got.process );
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
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    'node "-v"',
    { 'env' : null, 'cwd' : process.cwd(), 'shell' : true },
    undefined
  ]

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( 'node -v' ).sync();
  test.identical( got.exitCode, 0 );
  test.true( subprocessStartEndGot.proces !== got.process );
  test.true( subprocessTerminationEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function execFile( test )
{
  let self = this;

  function start( exec, args )
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
    ready.deasync();
    return ready.sync();
  }
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    'node',
    [ '-v' ]
  ]

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.process instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.true( subprocessStartEndGot.proces !== got.process );
  test.true( subprocessTerminationEndGot.proces !== got.process );
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
    test.true( _.bufferAnyIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    endCounter++
  }

  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( 'node -v' )
  test.identical( got.exitCode, 0 );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function execFileSync( test )
{
  let self = this;

  function start( exec, args )
  {
    var result = Object.create( null );
    try
    {
      result.process = ChildProcess.execFileSync( exec, args );
      result.exitCode = 0;
    }
    catch( err )
    {
      result.process = err;
      result.exitCode = result.process.status;
    }
    return result;
  }
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot, subprocessTerminationEndGot;

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
    test.true( _.bufferNodeIs( o.returned ) );
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  start( 'node', [ '-v' ] );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }

  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );
  test.true( subprocessStartEndGot.proces !== got.process );
  test.true( subprocessTerminationEndGot.proces !== got.process );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function watcherDisable( test )
{
  let subprocessStartBegin = () => {}
  let subprocessStartBegin2 = () => {}

  test.case = 'disabled try to disable again'
  test.mustNotThrowError( () => { debugger;_.process.watcherDisable() });

  test.case = 'disable with handler registered'
  _.process.watcherEnable();
  test.true( _.process.watcherIsEnabled() )
  _.process.on( 'subprocessStartBegin', subprocessStartBegin );
  _.process.on( 'subprocessStartBegin', subprocessStartBegin2 );
  test.shouldThrowErrorSync( () => _.process.watcherDisable() );
  test.true( _.process.watcherIsEnabled() )

  test.case = 'unregister handler then disable watcher'
  _.process.off( 'subprocessStartBegin', subprocessStartBegin );
  _.process.off( 'subprocessStartBegin', subprocessStartBegin2 );
  _.process.watcherDisable()
  test.true( !_.process.watcherIsEnabled() )

}

//

function internal( test )
{
  let context = this;

  context.globalNamespaceOpen( _global, 'namespaceForTest' );

  _.assert( !!_realGlobal_._globals_[ 'namespaceForTest' ] );

  if( ChildProcess._namespaces )
  test.true( !_.longHas( ChildProcess._namespaces, _global.wTools.process ) );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, undefined );

  _global.wTools.process.watcherEnable();
  test.true( _.longHas( ChildProcess._namespaces, _global.wTools ) );
  test.true( _global.wTools.process.watcherIsEnabled() );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, [] );

  _global.wTools.process.watcherDisable();
  test.true( !_global.wTools.process.watcherIsEnabled() );
  if( ChildProcess._namespaces )
  test.true( !_.longHas( ChildProcess._namespaces, _global.wTools ) );
  else
  test.identical( ChildProcess._namespaces, undefined );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, undefined );

  context.globalNamespaceClose();

  _.assert( _global === _wasGlobal );
}

internal.description =
`
Checks internal fields of child process and process watcher in on/off states.
Creates own global namespace for the test.
`

//

function patchHomeDir( test )
{
  let self = this;

  let start = _.process.starter
  ({
    execPath : _.strQuote( process.argv[ 0 ] ),
    mode : 'spawn',
    outputCollecting : 1
  });
  let homedirPath = _.path.nativize( self.suiteTempPath );

  let onPatch = ( o ) =>
  {
    o.arguments[ 2 ].env = Object.create( null );
    if( process.platform === 'win32' )
    o.arguments[ 2 ].env[ 'USERPROFILE' ] = homedirPath
    else
    o.arguments[ 2 ].env[ 'HOME' ] = homedirPath
  }

  _.process.watcherEnable();

  _.process.on( 'subprocessStartBegin', onPatch )


  return start({ args : [ '-e', `console.log( require('os').homedir() )` ] })
  .then( ( got ) =>
  {
    test.identical( got.exitCode, 0 );
    test.true( _.strHas( got.output, homedirPath ) );
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
      'stdio' : [ 'pipe', 'pipe', 'pipe' ],
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

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

  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

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

    if( !ChildProcess._namespaces )
    {
      test.true( !_.routineIs( ChildProcess._spawn ) );
      test.true( !_.routineIs( ChildProcess._execFile ) );
      test.true( !_.routineIs( ChildProcess._fork ) );
      test.true( !_.routineIs( ChildProcess._spawnSync ) );
      test.true( !_.routineIs( ChildProcess._execSync ) );
      test.true( !_.routineIs( ChildProcess._execFileSync ) );
    }

    return null;
  })

  return ready;
}

//

function spawnSyncError( test )
{
  let self = this;

  let start = _.process.starter({ sync : 1, mode : 'spawn' });
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot, subprocessTerminationEndGot;

  var expectedArguments =
  [
    'node',
    [ '-e', 'throw 1' ],
    {
      'stdio' : [ 'pipe', 'pipe', 'pipe' ],
      'detached' : false,
      'cwd' : process.cwd(),
      'windowsHide' : true
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

  let subprocessStartEnd = ( o ) =>
  {
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.identical( o.arguments, expectedArguments );
    subprocessTerminationEndGot = o;
    endCounter++
  }

  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();
  test.true( _.routineIs( ChildProcess._spawn ) );
  test.true( _.routineIs( ChildProcess._execFile ) );
  test.true( _.routineIs( ChildProcess._fork ) );
  test.true( _.routineIs( ChildProcess._spawnSync ) );
  test.true( _.routineIs( ChildProcess._execFileSync ) );

  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  test.shouldThrowErrorSync( () => start( 'node -e "throw 1"' ) );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !ChildProcess._namespaces )
  {
    test.true( !_.routineIs( ChildProcess._spawn ) );
    test.true( !_.routineIs( ChildProcess._execFile ) );
    test.true( !_.routineIs( ChildProcess._fork ) );
    test.true( !_.routineIs( ChildProcess._spawnSync ) );
    test.true( !_.routineIs( ChildProcess._execSync ) );
    test.true( !_.routineIs( ChildProcess._execFileSync ) );
  }
}

//

function detached( test )
{
  let context = this;
  let a = context.assetFor( test, null );

  let testAppPath = a.path.nativize( a.program( testApp ) );

  let startBegin = 0;
  let startEnd = 0;
  let endCounter = 0;
  let descriptor = null;

  let subprocessStartBegin = ( o ) =>
  {
    startBegin++
  }

  let subprocessStartEnd = ( o ) =>
  {
    startEnd++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    descriptor = o;
    endCounter++
  }

  test.identical( startBegin, 0 );
  test.identical( startEnd, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();

  _.process.on( 'subprocessStartBegin', subprocessStartBegin )
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  let o =
  {
    execPath : 'node ' + testAppPath,
    mode : 'spawn',
    detaching : 1,
    stdio : 'pipe',
    outputPiping : 1
  }

  _.process.start( o );

  o.conStart.thenGive( () => o.disconnect() )

  let ready = _.time.out( context.t2 * 5 );

  ready.then( () =>
  {
    test.true( !_.process.isAlive( o.process.pid ) );
    test.identical( startBegin, 1 );
    test.identical( startEnd, 1 );
    test.identical( endCounter, 1 );

    test.identical( descriptor.terminated, true );
    test.identical( descriptor.terminationEvent, 'exit' );

    _.process.off( 'subprocessStartBegin', subprocessStartBegin )
    _.process.off( 'subprocessStartEnd', subprocessStartEnd )
    _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

    _.process.watcherDisable();

    return null;
  })

  /* */

  return ready;

  function testApp()
  {
    let _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    console.log( 'Child process start', process.pid )
    _.time.out( context.t2 * 3, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.toStr( process.pid ) );
      console.log( 'Child process end' )
      return null;
    })
  }
}

detached.description =
`
Checks that termination of detached and disconnected child process works
`

function watcherWaitForExit( test )
{
  let context = this;
  let a = context.assetFor( test, null );

  let testAppPath = a.path.nativize( a.program( testApp ) );

  let startBegin = 0;
  let startEnd = 0;
  let endCounter = 0;
  let descriptor = null;
  let processesCounterStartBegin = null;
  let processesCounterStartEnd = null;
  let processesCounterTerminateEnd = null;

  let subprocessStartBegin = ( o ) =>
  {
    startBegin++;
    processesCounterStartBegin = _.process.__watcherProcessDescriptors.length;
  }

  let subprocessStartEnd = ( o ) =>
  {
    startEnd++;
    processesCounterStartEnd = _.process.__watcherProcessDescriptors.length;
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    descriptor = o;
    endCounter++;
    processesCounterTerminateEnd = _.process.__watcherProcessDescriptors.length;
  }

  test.identical( startBegin, 0 );
  test.identical( startEnd, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();

  _.process.on( 'subprocessStartBegin', subprocessStartBegin )
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  let o =
  {
    execPath : 'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe',
    outputPiping : 1
  }

  _.process.start( o );

  let ready = _.process.watcherWaitForExit
  ({
    waitForAllNamespaces : 1,
    timeOut : context.t1 * 10
  })

  ready.then( () =>
  {
    test.true( !_.process.isAlive( o.process.pid ) );
    test.identical( startBegin, 1 );
    test.identical( startEnd, 1 );
    test.identical( endCounter, 1 );

    test.identical( descriptor.terminated, true );
    test.identical( descriptor.terminationEvent, 'close' );

    test.identical( processesCounterStartBegin, 0 );
    test.identical( processesCounterStartEnd, 1 );
    test.identical( processesCounterTerminateEnd, 0 );

    _.process.off( 'subprocessStartBegin', subprocessStartBegin )
    _.process.off( 'subprocessStartEnd', subprocessStartEnd )
    _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

    _.process.watcherDisable();

    return null;
  })

  /* */

  return ready;

  function testApp()
  {
    console.log( 'Child process start', process.pid );
    setTimeout( () =>
    {
      console.log( 'Child process end', process.pid );

    }, context.t1 * 5 )
  }
}

//

function watcherWaitForExitTimeOut( test )
{
  let context = this;
  let a = context.assetFor( test, null );

  let testAppPath = a.path.nativize( a.program( testApp ) );

  let startBegin = 0;
  let startEnd = 0;
  let endCounter = 0;
  let descriptor = null;
  let processesCounterStartBegin = null;
  let processesCounterStartEnd = null;
  let processesCounterTerminateEnd = null;

  let subprocessStartBegin = ( o ) =>
  {
    startBegin++;
    processesCounterStartBegin = _.process.__watcherProcessDescriptors.length;
  }

  let subprocessStartEnd = ( o ) =>
  {
    startEnd++;
    processesCounterStartEnd = _.process.__watcherProcessDescriptors.length;
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    descriptor = o;
    endCounter++;
    processesCounterTerminateEnd = _.process.__watcherProcessDescriptors.length;
  }

  test.identical( startBegin, 0 );
  test.identical( startEnd, 0 );
  test.identical( endCounter, 0 );

  _.process.watcherEnable();

  _.process.on( 'subprocessStartBegin', subprocessStartBegin )
  _.process.on( 'subprocessStartEnd', subprocessStartEnd )
  _.process.on( 'subprocessTerminationEnd', subprocessTerminationEnd )

  let o =
  {
    execPath : 'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe',
    outputPiping : 1
  }

  _.process.start( o );

  let ready = _.process.watcherWaitForExit
  ({
    waitForAllNamespaces : 1,
    timeOut : context.t1 * 2
  })

  ready.finally( ( err, arg ) =>
  {
    _.errAttend( err );
    test.true( _.errIs( err ) );
    test.identical( err.reason, 'time out' );
    return null;
  })

  o.conTerminate.then( () =>
  {
    test.true( !_.process.isAlive( o.process.pid ) );
    test.identical( startBegin, 1 );
    test.identical( startEnd, 1 );
    test.identical( endCounter, 1 );

    test.identical( descriptor.terminated, true );
    test.identical( descriptor.terminationEvent, 'close' );

    test.identical( processesCounterStartBegin, 0 );
    test.identical( processesCounterStartEnd, 1 );
    test.identical( processesCounterTerminateEnd, 0 );

    _.process.off( 'subprocessStartBegin', subprocessStartBegin )
    _.process.off( 'subprocessStartEnd', subprocessStartEnd )
    _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

    _.process.watcherDisable();

    return null;
  })

  /* */

  return _.Consequence.AndKeep( ready, o.conTerminate );

  function testApp()
  {
    console.log( 'Child process start', process.pid );
    setTimeout( () =>
    {
      console.log( 'Child process end', process.pid );

    }, context.t1 * 10 )
  }
}

// --
// test
// --

var Proto =
{

  name : 'Tools.l5.ProcessWatcher',
  silencing : 1,
  routineTimeOut : 60000,
  onSuiteBegin : suiteBegin,
  onSuiteEnd : suiteEnd,
  processWatching : 0,

  context :
  {
    suiteTempPath : null,
    toolsPath : null,
    toolsPathInclude : null,
    t0 : 100,
    t1 : 1000,
    t2 : 5000,
    t3 : 15000,
    isRunning,
    assetFor,
    globalNamespaceOpen,
    globalNamespaceClose
  },

  tests :
  {
    spawn,
    spawnSync,
    fork,
    // exec,
    execFile,
    // execSync,

    execFileSync,

    watcherDisable,
    internal,

    patchHomeDir,

    spawnError,
    spawnSyncError,

    detached,

    watcherWaitForExit,
    watcherWaitForExitTimeOut
  },

}

_.mapExtend( Self, Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
