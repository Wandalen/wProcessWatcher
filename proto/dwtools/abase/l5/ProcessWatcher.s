( function _ProcessWatcher_s_() {

'use strict';

/**
 * Collection of routines for child process monitoring. Allows to keep track of creation, spawn and termination of a child process via events. Get information about command, arguments and options used to create a child process. Modify command, arguments or options on the creation stage. Access instance of ChildProcess on spawn and termination stages.
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
  _.include( 'wAppBasic' )
}

let _global = _global_;
let _ = _global_.wTools;

// if( _realGlobal_ !== _global_ )
// if( _realGlobal_.wTools && _realGlobal_.wTools.process && _realGlobal_.wTools.process.watcherEnable )
// return ExportTo( _global_, _realGlobal_ );

_.assert( !!_global_.wTools, 'Does not have wTools' );
_.assert( _global_.wTools.process === undefined || _global_.wTools.process.watcherEnable === undefined, 'wProcessWatcher is already defined' );

let ChildProcess;
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

function watcherEnable()
{
  _.assert( arguments.length === 0 );
  
  if( !ChildProcess  )
  ChildProcess = require( 'child_process' );
  
  patch( 'spawn' );
  patch( 'fork' );
  patch( 'execFile' );
  patch( 'spawnSync' );
  patch( 'execFileSync' );
  patch( 'execSync' );

  _.mapSupplement( Self._eventCallbackMap, _eventCallbackMap );

  /* qqq : ?? */
  // _.process.on( 'exit', () =>
  // {
  //   if( _.process.watcherIsEnabled() )
  //   _.process.watcherDisable();
  // })

  return true;

  /*  */

  // qqq : why 2 different suroutines?
  // qqq Vova : merged subroutines

  function patch( routine )
  {
    let _routine = _.strPrependOnce( routine, '_' );

    _.assert( _.routineIs( ChildProcess[ routine ] ) );
    
    if( _.routineIs( ChildProcess[ _routine ] ) )
    return true;

    let original = ChildProcess[ _routine ] = ChildProcess[ routine ];
    let sync = _.strEnds( routine, 'Sync' );

    ChildProcess[ routine ] = function()
    { 
      if( sync )
      {
        var o =
        {
          arguments : Array.prototype.slice.call( arguments ),
          process : null,
          sync : 1
        }
        let procedure = _.procedure.begin({});
        _eventHandle( 'subprocessStartBegin', o )
        _eventHandle( 'subprocessStartEnd', o )
        try 
        {
          o.returned = original.apply( ChildProcess, arguments );
        }
        catch( err )
        {
          throw err;
        }
        finally
        {
          procedure.end();
          _eventHandle( 'subprocessTerminationEnd', o );
        }
        return o.returned;
      }
      
      var o =
      {
        arguments : Array.prototype.slice.call( arguments ),
        process : null,
        sync : 0
      }

      _eventHandle( 'subprocessStartBegin', o )

      o.process = original.apply( ChildProcess, arguments );

      if( !_.numberIs( o.process.pid ) )
      return o.process;

      /* qqq : enable storing of ChildProcess instance in _object, agree launch with _.process.start */
      let procedure = _.procedure.begin({ _name : 'PID:' + o.process.pid, /* qqq _object : o.process */ }); 

      _eventHandle( 'subprocessStartEnd', o )

      o.process.on( 'close', () =>
      {
        procedure.end();
        _eventHandle( 'subprocessTerminationEnd', o );
      });

      return o.process;
    }
  }

  /* */

  function _eventHandle( eventName, o )
  { 
    if( _global_._testerGlobal_.wTools.process )
    _eventHandleFor( _global_._testerGlobal_.wTools.process )
    
    if( _global_._testerGlobal_.wTools.process )
    _eventHandleFor( _global_.wTools.process )
    
    function _eventHandleFor( processNamespace )
    { 
      if( !watcherIsEnabled.call( processNamespace ) )
      return;
      if( !processNamespace._eventCallbackMap[ eventName ].length )
      return;
  
      let callbacks = processNamespace._eventCallbackMap[ eventName ].slice();
      callbacks.forEach( ( callback ) =>
      {
        try
        {
          callback.call( processNamespace, o );
        }
        catch( err )
        {
          throw _.err( `Error in handler::${callback.name} of an event::available of module::ProcessWatcher\n`, err );
        }
      });
    }

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
  let processNamespace = this;
  _.each( _eventCallbackMap, ( handlers, eventName ) =>
  {
    if( !processNamespace._eventCallbackMap[ eventName ] )
    return;
    if( handlers.length )
    { 
      let errMsg;
      
      if( Config.debug )
      { 
        let locations = handlers.map( ( handler ) => handler._callLocation ).join( '\n ' );
        errMsg = `Event ${eventName} has registered handlers:\n ${locations}`;
      }
      else
      { 
        if( handlers.length === 1 )
        errMsg = `Event ${eventName} has registered handler "${handlers[ 0 ].name}".`;
        else
        errMsg = `Event ${eventName} has ${handlers.length} registered handlers.`;
      }
      
      throw _.err( errMsg + '\nPlease use _.process.off to unregister handlers.' );
      // qqq : use ` instead
      // qqq : not enough information!
      // qqq : bad naming. not "event"
      ///qqq Vova: done
    }
    delete processNamespace._eventCallbackMap[ eventName ];
  })

  if( ChildProcess )
  {
    unpatch( 'spawn' );
    unpatch( 'fork' );
    unpatch( 'execFile' );
    unpatch( 'spawnSync' )
    unpatch( 'execFileSync' )
    unpatch( 'execSync' )
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
  let processNamespace = this;
  for( var eventName in _eventCallbackMap )
  if( processNamespace._eventCallbackMap[ eventName ] )
  return true;
  return false;
}

//

let _on = _.process.on;
function on()
{  
  if( arguments.length === 2 )
  if( _eventCallbackMap[ arguments[ 0 ] ] )
  {  
    _.assert( _.routineIs( arguments[ 1 ] ) );
    arguments[ 1 ]._callLocation = _.introspector.stack([ 1, 2 ]);
  }
  let o2 = _on.apply( this, arguments );
  return o2;
}

on.defaults =
{
  callbackMap : null,
}

// --
// meta
// --

// function ExportTo( dstGlobal, srcGlobal )
// {
//   _.assert( _.mapIs( srcGlobal.wTools.process ) );
//   _.mapExtend( dstGlobal.wTools, { process : srcGlobal.wTools.process });
//   if( typeof module !== 'undefined' && module !== null );
//   module[ 'exports' ] = dstGlobal.wTools.process;
// }

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

let NamespaceBlueprint =
{
  watcherEnable,
  watcherDisable,
  watcherIsEnabled,
}

_.construction.extend( _.process, NamespaceBlueprint );

if( Config.debug )
_.construction.extend( _.process, { on } );


// --
// export
// --

// if( _realGlobal_ !== _global_ )
// return ExportTo( _realGlobal_, _global_ );

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _.process;

})();
