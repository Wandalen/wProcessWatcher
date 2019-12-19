( function _ProcessWatcher_s_() {

'use strict';

/**
 * Collection of routines to watch child process. Register/unregister handlers for child process start/close.
  @module Tools/base/ProcessWatcher
*/

/**
 * @file ProcessWatcher.s.
 */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../Tools.s' );
  _.include( 'wProto' )
  _.include( 'wProcedure' )
}

let ChildProcess;
let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools.process = _global_.wTools.process || Object.create( null );

//

/**
 * @summary Enable watch for child process start/end.
 * @description
 * Patches NodeJs ChildProcess module to hook child process creation.
 * Adds provided `o.onBegin` and `o.onEnd` handlers to internal queue.
 * `o.onBegin` handler is executed when child process is created.
 * `o.onEnd` handler is executed when child process is closed.
 * Each handler will receive single argument - instance of ChildProcess created by one of methods: exec,execFile,spawn,fork.
 * Handlers are executed in the order of their registration.
 * Doesn't register handler that already exists in internal queue.
 *
 * @param {Object} o Options map.
 * @param {Object} o.onBegin=null Routine to execute when new child process is created.
 * @param {Object} o.onEnd=null Routine to execute when watched child process is closed.
 *
 * @return {Object} Returns ProcessWatcher instance.
 *
 * @function watcherEnable
 * @memberof module:Tools/base/ProcessWatcher.Tools( module::ProcessWatcher )
 */

let watcherEnabledTimes = 0;

function watcherEnable()
{ 
  _.assert( arguments.length === 0 );
  
  if( !ChildProcess )
  {
    ChildProcess = require( 'child_process' );

    if( _.process._watcher === null )
    {
      _.process._watcher = Object.create( null );
      _.process._watcher.onBegin = [];
      _.process._watcher.onEnd = [];
      _.process._watcher.onPatch = [];
    }

    patch( 'spawn' );
    patch( 'fork' );
    patch( 'execFile' );
    patchSync( 'spawnSync' )
    patchSync( 'execFileSync' )
    
    _.mapSupplement( Self._eventCallbackMap, _eventCallbackMap );
    
    _.process.on( 'exit', () => 
    {
      if( _.process.watcherIsEnabled() )
      throw _.err( 'ProcessWatcher was not disabled.' )
    })
    
  }
  
  watcherEnabledTimes += 1;
  
  return true;
  
  /*  */

  function patch( routine )
  {
    let _routine = _.strPrependOnce( routine, '_' );

    _.assert( _.routineIs( ChildProcess[ routine ] ) );
    _.assert( !_.routineIs( ChildProcess[ _routine ] ) );

    let original = ChildProcess[ _routine ] = ChildProcess[ routine ];

    ChildProcess[ routine ] = function()
    { 
      var o = 
      {
        arguments : Array.prototype.slice.call( arguments ),
        process : null
      }
      
      _eventHandle( 'subprocessStartBegin', o )
      
      o.process = original.apply( ChildProcess, arguments );
      
      let procedure = _.procedure.begin({ _name : 'PID:' + o.process.pid, /* qqq _object : childProcess */ });
      
      _eventHandle( 'subprocessStartEnd', o )
      
      o.process.on( 'close', () => 
      {  
        procedure.end();
        _eventHandle( 'subprocessTerminationEnd', o );
      });
      
      return o.process;
    }
  }

  //

  function patchSync( routine )
  {
    let _routine = _.strPrependOnce( routine, '_' );

    _.assert( _.routineIs( ChildProcess[ routine ] ) );
    _.assert( !_.routineIs( ChildProcess[ _routine ] ) );

    let original = ChildProcess[ _routine ] = ChildProcess[ routine ];

    ChildProcess[ routine ] = function()
    { 
      var o = 
      {
        arguments : Array.prototype.slice.call( arguments ),
        process : null
      }
      let procedure = _.procedure.begin({});
      _eventHandle( 'subprocessStartBegin', o )
      _eventHandle( 'subprocessStartEnd', o )
      o.returned = original.apply( ChildProcess, arguments );
      procedure.end();
      _eventHandle( 'subprocessTerminationEnd', o );
      return o.returned;
    }
  }
  
  function _eventHandle( event, o )
  { 
    if( !_.process._eventCallbackMap[ event ].length )
    return;

    let callbacks = _.process._eventCallbackMap[ event ].slice();
    callbacks.forEach( ( callback ) =>
    {
      try
      {
        callback.call( _.process, o );
      }
      catch( err )
      {
        throw _.err( `Error in handler::${callback.name} of an event::available of module::ProcessWatcher\n`, err );
      }
    });

  }
}

//

/**
 * @summary Disable watch for child process start/end.
 * @description
 * Restores original methods of NodeJs ChildProcess module.
 * Removes all registered `o.onBegin` and `o.onEnd` handler(s) if routine was executed without arguments.
 * Removes specified `o.onBegin` and `o.onEnd` handler if it was provided through option.
 * Does nothing if specified handler doesn't exist in internal queue.
 * @param {Object} o Options map.
 * @param {Object} o.onBegin=null Routine to execute when new child process is created.
 * @param {Object} o.onEnd=null Routine to execute when watched child process is closed.
 *
 * @return {Object} Returns ProcessWatcher instance.
 *
 * @function watcherEnable
 * @memberof module:Tools/base/ProcessWatcher.Tools( module::ProcessWatcher )
 */

function watcherDisable()
{  
  if( !watcherEnabledTimes )
  return;
  
  watcherEnabledTimes -= 1;
  
  if( watcherEnabledTimes )
  return;
    
  _.each( _eventCallbackMap, ( handlers, event ) => 
  { 
    if( !_.process._eventCallbackMap[ event ] )
    return;
    if( _.process._eventCallbackMap, handlers.length )
    throw _.err( 'Event', event, 'has', handlers.length,  'registered handlers.\nPlease use _.process.off to unregister handlers.' );
    delete Self._eventCallbackMap[ event ];
  })
  
  if( ChildProcess )
  {
    unpatch( 'spawn' );
    unpatch( 'fork' );
    unpatch( 'execFile' );
    unpatch( 'spawnSync' )
    unpatch( 'execFileSync' )
    ChildProcess = null;
  }

  return true;

  /*  */

  function unpatch( routine )
  {
    let _routine = _.strPrependOnce( routine, '_' );
    _.assert( _.routineIs( ChildProcess[ _routine ] ) );
    ChildProcess[ routine ] = ChildProcess[ _routine ];
    delete ChildProcess[ _routine ];
  }
}

//

function watcherIsEnabled()
{
  for( var event in _eventCallbackMap )
  if( _.process._eventCallbackMap[ event ] )
  return true;
  return false;
}

// --
// declare
// --

let _eventCallbackMap =
{
  subprocessStartBegin  : [],
  subprocessStartEnd  : [],
  // subprocessTerminationBegin  : [],
  subprocessTerminationEnd  : []
}

let Fields =
{
}

let Routines =
{ 
  watcherEnable,
  watcherDisable,
  watcherIsEnabled,
}

_.mapExtend( Self, Fields );
_.mapExtend( Self, Routines );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
