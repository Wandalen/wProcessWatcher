( function _ProcessWatcher_test_s( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );

  _.include( 'wTesting' );
  _.include( 'wFiles' );
  _.include( 'wAppBasic' );

  require( '../l4/ProcessWatcher.s' );
  
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

function trivial( test )
{
  let self = this;
  
  let start = _.process.starter({ deasync : 1 });
  let beginCounter = 0;
  let endCounter = 0;
  
  let onBegin = ( got ) => 
  { 
    test.is( got instanceof ChildProcess.ChildProcess )
    beginCounter++
  }
  let onEnd = ( got ) => 
  { 
    test.is( got instanceof ChildProcess.ChildProcess )
    endCounter++
  }
  
  let watcher = new _.process.ProcessWatcher();
  
  start( 'node -v' );
  test.identical( beginCounter, 0 );
  test.identical( endCounter, 0 );
  
  watcher.watchMaking({ onBegin, onEnd });
  test.is( _.routineIs( ChildProcess._spawn ) );
  test.is( _.routineIs( ChildProcess._exec ) );
  test.is( _.routineIs( ChildProcess._execFile ) );
  test.is( _.routineIs( ChildProcess._fork ) );
  start( 'node -v' );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
  watcher.unwatchMaking();
  test.is( !_.routineIs( ChildProcess._spawn ) );
  test.is( !_.routineIs( ChildProcess._exec ) );
  test.is( !_.routineIs( ChildProcess._execFile ) );
  test.is( !_.routineIs( ChildProcess._fork ) );
  start( 'node -v' );
  test.identical( beginCounter, 1 );
  test.identical( endCounter, 1 );
  
}

//

function killZombieProcess( test )
{
  let self = this;
  let childProcess = null;
  
  function onBegin( child )
  {
    childProcess = child;
  }
  
  let watcher = new _.process.ProcessWatcher();
  watcher.watchMaking({ onBegin });
  
  _.process.start
  ({ 
    execPath : 'node -e "setTimeout( () => {}, 100000000 )"',
    throwingExitCode : 0 
  });
  
  let ready = _.timeOut( 3000 );
  
  ready.then( () => 
  {
    test.is( childProcess instanceof ChildProcess.ChildProcess );
    test.is( self.isRunning( childProcess.pid ) );
    childProcess.kill();
    test.is( !self.isRunning( childProcess.pid ) );
    return null;
  })
  
  return ready;
}

killZombieProcess.timeOut = 5000;

// --
// test
// --

//

var Proto =
{

  name : 'Tools.base.l4.ProcessWatcher',
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
    trivial,
    killZombieProcess
  },

}

_.mapExtend( Self,Proto );

//

Self = wTestSuite( Self );

if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self )

})();
