const { Z_ASCII } = require('zlib');

( function _ProcessWatcher_test_s( )
{

'use strict';

let ChildProcess;

if( typeof module !== 'undefined' )
{

  const _ = require( '../../../node_modules/Tools' );

  require( '../l5/ProcessWatcher.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wProcess' );

  ChildProcess = require( 'child_process' );

}

const _global = _global_;
const _ = _global_.wTools;
const _realGlobal = _global._realGlobal_;

// --
// context
// --

function suiteBegin()
{
  var self = this;
  self.suiteTempPath = _.path.tempOpen( _.path.join( __dirname, '../..' ), 'ProcessWatcher' );
  self.toolsPath = _.path.nativize( _.path.resolve( __dirname, '../../../node_modules/Tools' ) );
  self.toolsPathInclude = `const _ = require( '${ _.strEscape( self.toolsPath ) }' )\n`;
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
  a.program = _.routine.uniteCloning_( a.program.head, program_body );
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

// //
//
// /* xxx : qqq : remove */
// let _wasGlobal, _wasCache;
// function globalNamespaceOpen( _global, name )
// {
//   if( _realGlobal_._globals_[ name ] )
//   throw Error( `Global namespace::${name} already exists!` );
//   let ModuleFileNative = require( 'module' );
//   if( _global.moduleNativeFilesMap && _global.moduleNativeFilesMap !== ModuleFileNative._cache )
//   throw Error( `Current global have native module files map of different global` );
//   _global.moduleNativeFilesMap = ModuleFileNative._cache;
//   _wasCache = ModuleFileNative._cache;
//   _wasGlobal = _global;
//   ModuleFileNative._cache = Object.create( null );
//   _global = Object.create( _global );
//   _global.moduleNativeFilesMap = ModuleFileNative._cache;
//   _global.__GLOBAL_NAME__ = name;
//   _global._global_ = _global;
//   _realGlobal_._global_ = _global;
//   _realGlobal_._globals_[ name ] = _global;
//   if( module.nativeFilesMap )
//   module.nativeFilesMap = ModuleFileNative._cache;
//   return _global;
// }
//
// //
//
// function globalNamespaceClose()
// {
//   let ModuleFileNative = require( 'module' );
//   ModuleFileNative._cache = _wasCache;
//   _global_ = _wasGlobal;
// }

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
      'cwd' : _.path.nativize( _.path.current() ),
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
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
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

  var expectedOptions =
  {
    stdio : [ 'pipe', 'pipe', 'pipe' ],
    detached : false,
    cwd : _.path.nativize( _.path.current() ),
    windowsHide : true,
  }
  if( process.platform !== 'win32' )
  _.mapExtend( expectedOptions, { uid : null, gid : null } );
  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    options : expectedOptions,
    currentPath : _.path.nativize( _.path.current() ),
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, got.pnd );
  test.identical( subprocessTerminationEndGot.pnd, got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
  test.true( subprocessStartEndGot.pnd !== got.pnd );
  test.true( subprocessTerminationEndGot.pnd !== got.pnd );
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
      'cwd' : _.path.nativize( _.path.current() ),
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
    test.identical( o.pnd, null )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.identical( o.pnd, null )
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

  var expectedOptions =
  {
    stdio : [ 'pipe', 'pipe', 'pipe' ],
    detached : false,
    cwd : _.path.nativize( _.path.current() ),
    windowsHide : true,
  }
  if( process.platform !== 'win32' )
  _.mapExtend( expectedOptions, { uid : null, gid : null } );
  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    options : expectedOptions,
    currentPath : _.path.nativize( _.path.current() ),
    sync : true,
    terminated : true,
    terminationEvent : null
  }
  test.contains( subprocessStartEndGot, expected )

  test.true( _.objectIs( subprocessStartEndGot.returned ) )

  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
      'cwd' : _.path.nativize( _.path.current() )
    }
  ]

  if( process.platform !== 'win32' )
  {
    expectedArguments[ 2 ].uid = null;
    expectedArguments[ 2 ].gid = null;
  }

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
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

  var expectedOptions =
  {
    stdio : [ 'pipe', 'pipe', 'pipe', 'ipc' ],
    detached : false,
    cwd : _.path.nativize( _.path.current() ),
    env : null,
    execArgv : []
  }
  if( process.platform !== 'win32' )
  _.mapExtend( expectedOptions, { uid : null, gid : null } );
  var expected =
  {
    arguments : expectedArguments,
    execPath : '-v',
    args : [],
    options : expectedOptions,
    currentPath : _.path.nativize( _.path.current() ),
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, got.pnd );
  test.identical( subprocessTerminationEndGot.pnd, got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
  test.true( subprocessStartEndGot.pnd !== got.pnd );
  test.true( subprocessTerminationEndGot.pnd !== got.pnd );
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
    { 'env' : null, 'cwd' : _.path.nativize( _.path.current() ), 'shell' : true },
    undefined
  ]

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
    test.identical( o.arguments, expectedArguments );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
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
  test.identical( subprocessStartEndGot.pnd, got.pnd );
  test.identical( subprocessTerminationEndGot.pnd, got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
  test.true( subprocessStartEndGot.pnd !== got.pnd );
  test.true( subprocessTerminationEndGot.pnd !== got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
}

//

function execFile( test )
{
  let self = this;

  function start( exec, args, options )
  {
    let ready = new _.Consequence();
    var childProcess = ChildProcess.execFile( exec, args, options );
    var result = { pnd : childProcess };
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

  let subprocessStartEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.true( o.pnd instanceof ChildProcess.ChildProcess )
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

  /* - */

  test.case = 'no options'
  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );

  var expectedArguments =
  [
    'node',
    [ '-v' ]
  ]

  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    currentPath : _.path.current(),
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, got.pnd );
  test.identical( subprocessTerminationEndGot.pnd, got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  /* */

  test.case = 'with options'

  var got = start( 'node', [ '-v' ], { cwd : __dirname } )
  test.identical( got.exitCode, 0 );

  var expectedArguments =
  [
    'node',
    [ '-v' ],
    { cwd : __dirname }
  ]

  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    currentPath : __dirname,
    options : { cwd : __dirname },
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, got.pnd );
  test.identical( subprocessTerminationEndGot.pnd, got.pnd );
  test.identical( beginCounter, 2 );
  test.identical( endCounter, 2 );

  /* - */

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
  test.true( subprocessStartEndGot.pnd !== got.pnd );
  test.true( subprocessTerminationEndGot.pnd !== got.pnd );
  test.identical( beginCounter, 2 );
  test.identical( endCounter, 2 );

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
    { 'env' : null, 'cwd' : _.path.nativize( _.path.current() ) },
  ]

  let subprocessStartEnd = ( o ) =>
  {
    test.identical( o.pnd, null );
    test.identical( o.arguments, expectedArguments );
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.identical( o.pnd, null );
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
  if( !_realGlobal_._ProcessWatcherNamespaces )
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

  function start( exec, args, options )
  {
    var result = Object.create( null );
    try
    {
      result.pnd = ChildProcess.execFileSync( exec, args, options );
      result.exitCode = 0;
    }
    catch( err )
    {
      result.pnd = err;
      result.exitCode = result.pnd.status;
    }
    return result;
  }
  let beginCounter = 0;
  let endCounter = 0;
  let subprocessStartEndGot, subprocessTerminationEndGot;

  let subprocessStartEnd = ( o ) =>
  {
    test.identical( o.pnd, null );
    subprocessStartEndGot = o;
    beginCounter++
  }
  let subprocessTerminationEnd = ( o ) =>
  {
    test.identical( o.pnd, null );
    test.true( _.bufferNodeIs( o.returned ) );
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

  /* - */

  test.case = 'no options'
  var got = start( 'node', [ '-v' ] )
  test.identical( got.exitCode, 0 );

  var expectedArguments =
  [
    'node',
    [ '-v' ]
  ]

  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    currentPath : _.path.current(),
    sync : true,
    terminated : true,
    terminationEvent : null
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, null );
  test.identical( subprocessTerminationEndGot.pnd, null );
  test.identical( subprocessTerminationEndGot.returned, got.pnd );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );

  /* - */

  test.case = 'with options '
  var got = start( 'node', [ '-v' ], { cwd : __dirname } )
  test.identical( got.exitCode, 0 );

  var expectedArguments =
  [
    'node',
    [ '-v' ],
    { cwd : __dirname }
  ]

  var expected =
  {
    arguments : expectedArguments,
    execPath : 'node',
    args : [ '-v' ],
    options : { cwd : __dirname },
    currentPath : __dirname,
    sync : true,
    terminated : true,
    terminationEvent : null
  }
  test.contains( subprocessStartEndGot, expected )

  test.identical( subprocessStartEndGot.pnd, null );
  test.identical( subprocessTerminationEndGot.pnd, null );
  test.identical( subprocessTerminationEndGot.returned, got.pnd );
  test.identical( beginCounter, 2 );
  test.identical( endCounter, 2 );

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )
  _.process.off( 'subprocessTerminationEnd', subprocessTerminationEnd )

  _.process.watcherDisable();
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
  test.true( subprocessStartEndGot.pnd !== got.pnd );
  test.true( subprocessTerminationEndGot.pnd !== got.pnd );
  test.identical( beginCounter, 2 );
  test.identical( endCounter, 2 );
}

//

function processDescriptor( test )
{
  let self = this;

  let startSpawn = _.process.starter({ deasync : 1, mode : 'spawn' });
  let subprocessStartEndGot;

  let subprocessStartEnd = ( o ) =>
  {
    subprocessStartEndGot = o;
  }

  _.process.watcherEnable();

  _.process.on( 'subprocessStartEnd', subprocessStartEnd )

  /* */

  test.case = 'spawn with options, cwd is calculated by start'
  startSpawn( 'node -v' ).sync();
  var expectedOptions =
  {
    stdio : [ 'pipe', 'pipe', 'pipe' ],
    detached : false,
    cwd : _.path.nativize( _.path.current() ),
    windowsHide : true,
  }
  if( process.platform !== 'win32' )
  _.mapExtend( expectedOptions, { uid : null, gid : null } );
  var expected =
  {
    arguments : [ 'node', [ '-v' ], expectedOptions ],
    execPath : 'node',
    args : [ '-v' ],
    options : expectedOptions,
    currentPath : _.path.nativize( _.path.current() ),
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )
  test.true( subprocessStartEndGot.pnd instanceof ChildProcess.ChildProcess );

  /* */

  test.case = 'spawn with options, cwd is provided as option'
  startSpawn({ execPath : 'node -v', currentPath : __dirname }).sync();
  var expectedOptions =
  {
    stdio : [ 'pipe', 'pipe', 'pipe' ],
    detached : false,
    cwd : __dirname,
    windowsHide : true,
  }
  if( process.platform !== 'win32' )
  _.mapExtend( expectedOptions, { uid : null, gid : null } );
  var expected =
  {
    arguments : [ 'node', [ '-v' ], expectedOptions ],
    execPath : 'node',
    args : [ '-v' ],
    options : expectedOptions,
    currentPath : __dirname,
    sync : false,
    terminated : true,
    terminationEvent : 'close'
  }
  test.contains( subprocessStartEndGot, expected )
  test.true( subprocessStartEndGot.pnd instanceof ChildProcess.ChildProcess );

  /* */

  test.case = 'no spawn options'
  ChildProcess.spawnSync( 'node', [ '-v' ] );
  var expected =
  {
    arguments : [ 'node', [ '-v' ] ],
    execPath : 'node',
    args : [ '-v' ],
    currentPath : _.path.current(),
    sync : true,
    terminated : true,
  }
  test.contains( subprocessStartEndGot, expected )
  test.true( _.objectIs( subprocessStartEndGot.returned ) );

  /* - */

  _.process.off( 'subprocessStartEnd', subprocessStartEnd )

  _.process.watcherDisable();
}

//

function watcherDisable( test )
{
  let subprocessStartBegin = () => {}
  let subprocessStartBegin2 = () => {}

  test.case = 'disabled try to disable again'
  test.mustNotThrowError( () => { _.process.watcherDisable() });

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

/* qqq : rewrite the test in separate pgroam.
test that __GLOBAL_NAME__ of modules files of process watcher has proper value ( namespaceForTest )
_.module.fileSetEnvironment( module, 'namespaceForTest' );
*/
function internal( test )
{
  let context = this;
  let _wasGlobal = _global_;

  // context.globalNamespaceOpen( _global, 'namespaceForTest' );
  _.global.new( 'namespaceForTest', _global );
  _.global._open( 'namespaceForTest' );

  test.true( _global_ !== _wasGlobal );

  _.assert( !!_realGlobal_._globals_[ 'namespaceForTest' ] );

  if( _realGlobal_._ProcessWatcherNamespaces )
  test.true( !_.longHas( _realGlobal_._ProcessWatcherNamespaces, _global.wTools.process ) );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, undefined );

  _global.wTools.process.watcherEnable();
  test.true( _.longHas( _realGlobal_._ProcessWatcherNamespaces, _global.wTools ) );
  test.true( _global.wTools.process.watcherIsEnabled() );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, [] );

  _global.wTools.process.watcherDisable();
  test.true( !_global.wTools.process.watcherIsEnabled() );
  if( _realGlobal_._ProcessWatcherNamespaces )
  test.true( !_.longHas( _realGlobal_._ProcessWatcherNamespaces, _global.wTools ) );
  else
  test.identical( _realGlobal_._ProcessWatcherNamespaces, undefined );
  test.identical( _global.wTools.process.__watcherProcessDescriptors, undefined );

  _.global._close( 'namespaceForTest' );
  // context.globalNamespaceClose();

  test.true( _global_ === _wasGlobal );
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
      'cwd' : _.path.nativize( _.path.current() ),
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
    test.identical( o.pnd, null );
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

    if( !_realGlobal_._ProcessWatcherNamespaces )
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
      'cwd' : _.path.nativize( _.path.current() ),
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
  if( !_realGlobal_._ProcessWatcherNamespaces )
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
    test.true( !_.process.isAlive( o.pnd.pid ) );
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
    const _ = require( toolsPath );
    _.include( 'wProcess' );
    _.include( 'wFiles' );
    console.log( 'Child process start', process.pid )
    _.time.out( context.t2 * 3, () =>
    {
      let filePath = _.path.join( __dirname, 'testFile' );
      _.fileProvider.fileWrite( filePath, _.entity.exportString( process.pid ) );
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
    test.true( !_.process.isAlive( o.pnd.pid ) );
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
    test.true( !_.process.isAlive( o.pnd.pid ) );
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
// events
// --

function onAnotherEvents( test )
{
  let context = this;
  let a = context.assetFor( test, null );
  let testAppPath = a.path.nativize( a.program( testApp ) );

  /* */

  test.case = 'add event of original _.process, single call';
  var arr = [];
  var callback = () => arr.push( 'string' );
  var got = _.process.on( 'available', callback );
  test.true( _.mapIs( got.available ) );
  test.identical( _.strCount( callback._callLocation, 'at Object.onAnotherEvents' ), 1 );
  _.process.eventGive( 'available' );
  test.identical( arr, [ 'string' ] );

  /* */

  test.case = 'add event of original _.process, several calls';
  var arr = [];
  var callback = () => arr.push( 'string' );
  var got = _.process.on( 'uncaughtError', callback );
  test.true( _.mapIs( got.uncaughtError ) );
  test.identical( _.strCount( callback._callLocation, 'at Object.onAnotherEvents' ), 1 );
  _.process.eventGive( 'uncaughtError' );
  _.process.eventGive( 'uncaughtError' );
  test.identical( arr, [ 'string', 'string' ] );
  got.uncaughtError.off();

  /* */

  test.case = 'add event available _.process, several calls';
  var arr = [];
  var callback = () => arr.push( 'string' );
  var got = _.process.on( 'available', callback );
  test.true( _.mapIs( got.available ) );
  test.identical( _.strCount( callback._callLocation, 'at Object.onAnotherEvents' ), 1 );
  _.process.eventGive( 'available' );
  _.process.eventGive( 'available' );
  test.identical( arr, [ 'string' ] );

  /* */

  test.case = 'add Chain with events of original _.process';
  var arr = [];
  var callback = () => arr.push( 'string' );
  var got = _.process.on( _.event.Chain( 'uncaughtError', 'uncaughtError', 'available' ), callback );
  test.identical( got.available, undefined );
  test.identical( _.process._ehandler.events.available, [] );
  test.identical( _.strCount( callback._callLocation, 'at Object.onAnotherEvents' ), 1 );
  _.process.eventGive( 'uncaughtError' );
  _.process.eventGive( 'uncaughtError' );
  test.identical( _.process._ehandler.events.available[ 0 ].native, callback );
  _.process.eventGive( 'available' );
  test.identical( arr, [ 'string' ] );

  /* */

  test.case = 'add event of ProcessWatcher';
  var arr = [];
  var callback = () => arr.push( 'string' );
  _.process.watcherEnable();
  var got = _.process.on( 'subprocessStartBegin', callback );
  test.identical( _.strCount( callback._callLocation, 'at Object.onAnotherEvents' ), 1 );
  test.true( _.mapIs( got.subprocessStartBegin ) );
  let o =
  {
    execPath : 'node ' + testAppPath,
    mode : 'spawn',
    stdio : 'pipe',
    outputPiping : 1,
  };
  _.process.start( o );
  let ready = _.process.watcherWaitForExit
  ({
    waitForAllNamespaces : 1,
    timeOut : context.t1 * 10
  })

  ready.then( () =>
  {
    test.true( !_.process.isAlive( o.pnd.pid ) );
    test.identical( arr, [ 'string' ] );
    _.process.off( 'subprocessStartBegin', callback );
    _.process.watcherDisable();

    return null;
  });

  return ready;

  /* - */

  if( !Config.debug )
  return;

  test.case = 'unknown event';
  test.shouldThrowErrorSync( () => _.process.on( 'event', () => 'event' ) );

  /* */

  function testApp()
  {
    console.log( 'Child process start', process.pid );
    setTimeout
    ( () =>
    {
      console.log( 'Child process end', process.pid );
    },
    context.t1 );
  }
}

onAnotherEvents.timeOut = 10000;

//

function onWithArguments( test )
{
  var self = this;

  /* */

  test.case = 'no callback for events';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [] );

  /* */

  test.case = 'single callback for single event, single event is given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on( 'uncaughtError', onEvent );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for single event, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on( 'uncaughtError', onEvent );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0, 1 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for each events in event handler, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.process._ehandler.events.event2 = [];
  var got = _.process.on( 'uncaughtError', onEvent );
  var got2 = _.process.on( 'event2', onEvent2 );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'event2' );
  _.event.eventGive( _.process._ehandler, 'event2' );
  delete _.process._ehandler.events.event2;
  test.identical( result, [ 0, 1, -2, -3 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  got.uncaughtError.off();
}

//

function onWithOptionsMap( test )
{
  var self = this;

  /* - */

  test.open( 'option first - 0' );

  test.case = 'no callback for events';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [] );

  /* */

  test.case = 'single callback for single event, single event is given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for single event, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } } );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0, 1 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent2 } ) );
  got.uncaughtError.off();

  /* */

  test.case = 'single callback for each events in event handler, a few events are given';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  _.process._ehandler.events.event2 = [];
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent, 'event2' : onEvent2 } });
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ 0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'event2' );
  _.event.eventGive( _.process._ehandler, 'event2' );
  delete _.process._ehandler.events.event2;
  test.identical( result, [ 0, 1, -2, -3 ] );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  got.uncaughtError.off();

  test.close( 'option first - 0' );

  /* - */

  test.open( 'option first - 1' );

  test.case = 'callback added before other callback';
  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ -0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ -0, 1, -2, 3 ] );
  got.uncaughtError.off();
  got2.uncaughtError.off();

  /* */

  test.case = 'callback added after other callback';

  var result = [];
  var onEvent = () => result.push( result.length );
  var onEvent2 = () => result.push( -1 * result.length );
  var got = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent2 }, 'first' : 1 });
  var got2 = _.process.on({ 'callbackMap' : { 'uncaughtError' : onEvent } });
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ -0, 1 ] );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [ -0, 1, -2, 3 ] );

  test.close( 'option first - 1' );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'without arguments';
  test.shouldThrowErrorSync( () => _.process.on() );

  test.case = 'wrong type of callback';
  test.shouldThrowErrorSync( () => _.process.on( 'uncaughtError', {} ) );

  test.case = 'wrong type of event name';
  test.shouldThrowErrorSync( () => _.process.on( [], () => 'str' ) );

  test.case = 'wrong type of options map o';
  test.shouldThrowErrorSync( () => _.process.on( 'wrong' ) );

  test.case = 'extra options in options map o';
  test.shouldThrowErrorSync( () => _.process.on({ callbackMap : {}, wrong : {} }) );

  test.case = 'not known event in callbackMap';
  test.shouldThrowErrorSync( () => _.process.on({ callbackMap : { unknown : () => 'unknown' } }) );
}

//

function onWithChain( test )
{
  var self = this;

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var got = _.process.on( _.event.Chain( 'uncaughtError', 'available' ), onEvent );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0 ] );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.off( _.process._ehandler, { callbackMap : { available : null } } );

  /* */

  test.case = 'call with options map';
  var result = [];
  var onEvent = () => result.push( result.length );
  var got = _.process.on({ callbackMap : { uncaughtError : [ _.event.Name( 'available' ), onEvent ] } });
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.eventGive( _.process._ehandler, 'uncaughtError' );
  test.identical( result, [] );
  _.event.eventGive( _.process._ehandler, 'available' );
  test.identical( result, [ 0 ] );
  test.false( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'available', eventHandler : onEvent } ) );
  _.event.off( _.process._ehandler, { callbackMap : { available : null } } );
}

//

function onCheckDescriptor( test )
{
  var self = this;

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var descriptor = _.process.on( 'uncaughtError', onEvent );
  test.identical( _.mapKeys( descriptor ), [ 'uncaughtError' ] );
  test.identical( _.mapKeys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
  test.identical( descriptor.uncaughtError.enabled, true );
  test.identical( descriptor.uncaughtError.first, 0 );
  test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  descriptor.uncaughtError.off();

  /* */

  test.case = 'call with arguments';
  var result = [];
  var onEvent = () => result.push( result.length );
  var descriptor = _.process.on({ callbackMap : { 'uncaughtError' : onEvent } });
  test.identical( _.mapKeys( descriptor ), [ 'uncaughtError' ] );
  test.identical( _.mapKeys( descriptor.uncaughtError ), [ 'off', 'enabled', 'first', 'callbackMap' ] );
  test.identical( descriptor.uncaughtError.enabled, true );
  test.identical( descriptor.uncaughtError.first, 0 );
  test.equivalent( descriptor.uncaughtError.callbackMap, { uncaughtError : onEvent } );
  test.true( _.event.eventHasHandler( _.process._ehandler, { eventName : 'uncaughtError', eventHandler : onEvent } ) );
  descriptor.uncaughtError.off();
}

// --
// test
// --

const Proto =
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
    // globalNamespaceOpen,
    // globalNamespaceClose
  },

  tests :
  {
    spawn,
    spawnSync,
    fork,
    // exec, /* qqq : for Vova : ? */
    execFile,
    // execSync, /* qqq : for Vova : ? */

    execFileSync,

    processDescriptor,

    watcherDisable,
    internal,

    patchHomeDir,

    spawnError,
    spawnSyncError,

    detached,

    watcherWaitForExit,
    watcherWaitForExitTimeOut,

    // events

    onAnotherEvents,
    onWithArguments,
    onWithOptionsMap,
    onWithChain,
    onCheckDescriptor,

  },

}

//

const Self = wTestSuite( Proto );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
