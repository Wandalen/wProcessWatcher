( function _ProcessWatcher_s_()
{

'use strict';

/**
 * Collection of cross-platform routines for child process monitoring. Allows to keep track of creation, spawn and termination of a child process via events. Get information about command, arguments and options used to create a child process. Modify command, arguments or options on the creation stage. Access instance of ChildProcess on spawn and termination stages.
  @module Tools/base/ProcessWatcher
 */

/**
 *  */

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../wtools/Tools.s' );
  _.include( 'wProto' )
  _.include( 'wProcedure' )
  _.include( 'wProcess' )
}

let ChildProcess;
let CurrentGlobal = _global_;
let _ = CurrentGlobal.wTools;

_.assert( !!CurrentGlobal.wTools, 'Does not have wTools' );
_.assert( CurrentGlobal.wTools.process === undefined || CurrentGlobal.wTools.process.watcherEnable === undefined, 'wProcessWatcher is already defined' );

let Self = CurrentGlobal.wTools.process = CurrentGlobal.wTools.process || Object.create( null );

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
 * @namespace wTools.process
 * @module Tools/base/ProcessWatcher
 */

function watcherEnable()
{
  let processNamespace = this;
  _.assert( arguments.length === 0, 'Expects no arguments' );

  if( !ChildProcess  )
  ChildProcess = require( 'child_process' );

  if( !_realGlobal_._ProcessWatcherNamespaces )
  _realGlobal_._ProcessWatcherNamespaces = []; /* qqq : ?? */

  _.assert( _.arrayIs( _realGlobal_._ProcessWatcherNamespaces ) );

  patch( 'spawn' );
  patch( 'fork' );
  patch( 'execFile' );
  patch( 'spawnSync' );
  patch( 'execFileSync' );
  patch( 'execSync' );

  _.mapSupplement( processNamespace._ehandler.events, Events );
  _.arrayAppendOnce( _realGlobal_._ProcessWatcherNamespaces, CurrentGlobal.wTools );

  if( processNamespace.__watcherProcessDescriptors === undefined )
  processNamespace.__watcherProcessDescriptors = [];

  return true;

  /*  */

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
      let o =
      {
        arguments : Array.prototype.slice.call( arguments ),
        execPath : arguments[ 0 ],
        args : arguments[ 1 ],
        options : arguments[ 2 ],
        currentPath : null,
        process : null,
        sync : null,
        terminated : false,
        terminationEvent : null
      }

      if( o.options )
      o.currentPath = o.options.cwd;
      else
      o.currentPath = process.cwd();

      if( sync )
      {
        o.sync = true;

        _eventHandle( 'subprocessStartBegin', o );
        _eventHandle( 'subprocessStartEnd', o );

        try
        {
          o.returned = original.apply( ChildProcess, arguments );
        }
        finally
        {
          _eventHandleTerminationEnd( o );
        }
        return o.returned;
      }

      o.sync = false;

      _eventHandle( 'subprocessStartBegin', o );

      o.pnd = original.apply( ChildProcess, arguments );

      if( !_.numberIs( o.pnd.pid ) )
      return o.pnd;

      _eventHandleStartEnd( o );

      /* Uses exit event to handle termination of disconnected and detached process */

      o.pnd.on( 'exit', () =>
      {
        /*
          Give a chance for 'close' event to emit 'subprocessTerminationEnd'
        */
        setTimeout( () =>
        {
          o.terminationEvent = 'exit';
          _eventHandleTerminationEnd( o );
        }, 100 )
      });

      o.pnd.on( 'close', () =>
      {
        o.terminationEvent = 'close';
        _eventHandleTerminationEnd( o );
      });

      return o.pnd;
    }
  }

  /* */

  function _eventHandle( eventName, descriptor )
  {
    _realGlobal_._ProcessWatcherNamespaces.forEach( ( wTools ) =>
    {
      if( !wTools.process.watcherIsEnabled() )
      return;
      if( !wTools.process._ehandler.events[ eventName ].length )
      return;
      let callbacks = wTools.process._ehandler.events[ eventName ].slice();
      callbacks.forEach( ( callback ) =>
      {
        try
        {
          callback.call( wTools.process, descriptor );
        }
        catch( err )
        {
          throw _.err( `Error in handler::${callback.name} of an event::available of module::ProcessWatcher\n`, err );
        }
      });
    });
  }

  /* */

  function _eventHandleStartEnd( descriptor )
  {
    _realGlobal_._ProcessWatcherNamespaces.forEach( ( wTools ) =>
    {
      if( !wTools.process.watcherIsEnabled() )
      return;
      _.arrayAppendOnce( wTools.process.__watcherProcessDescriptors, descriptor );
    });

    _eventHandle( 'subprocessStartEnd', descriptor );
  }

  function _eventHandleTerminationEnd( descriptor )
  {
    if( descriptor.terminated )
    return;
    descriptor.terminated = true;

    _realGlobal_._ProcessWatcherNamespaces.forEach( ( wTools ) =>
    {
      if( !wTools.process.watcherIsEnabled() )
      return;
      _.arrayRemoveOnce( wTools.process.__watcherProcessDescriptors, descriptor );
    });

    _eventHandle( 'subprocessTerminationEnd', descriptor );
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
 * @namespace wTools.process
 * @module Tools/base/ProcessWatcher
 */

function watcherDisable()
{
  let processNamespace = this;
  _.each( Events, ( handlers, eventName ) =>
  {
    if( !processNamespace._ehandler.events[ eventName ] )
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

      throw _.err( errMsg + `\nPlease use _.process.off to unregister handlers.` );
      // qqq : use ` instead
      // qqq : not enough information!
      // qqq : bad naming. not "event"
      ///qqq Vova: done
    }
    delete processNamespace._ehandler.events[ eventName ];
  })

  if( !ChildProcess  )
  ChildProcess = require( 'child_process' );

  if( !_realGlobal_._ProcessWatcherNamespaces )
  return true;

  _.arrayRemoveOnce( _realGlobal_._ProcessWatcherNamespaces, CurrentGlobal.wTools );

  delete processNamespace.__watcherProcessDescriptors;

  if( _realGlobal_._ProcessWatcherNamespaces.length )
  return true;

  unpatch( 'spawn' );
  unpatch( 'fork' );
  unpatch( 'execFile' );
  unpatch( 'spawnSync' )
  unpatch( 'execFileSync' )
  unpatch( 'execSync' )

  delete _realGlobal_._ProcessWatcherNamespaces;

  return true;

  /*  */

  function unpatch( routine )
  {
    let _routine = _.strPrependOnce( routine, '_' );
    _.assert( _.routineIs( ChildProcess[ routine ] ) );
    if( !_.routineIs( ChildProcess[ _routine ] ) )
    return;
    ChildProcess[ routine ] = ChildProcess[ _routine ];
    delete ChildProcess[ _routine ];
  }
}

//

function watcherIsEnabled()
{
  let processNamespace = this;
  for( var eventName in Events )
  if( processNamespace._ehandler.events[ eventName ] )
  return true;
  return false;
}

function watcherWaitForExit( o )
{
  let processNamespace = this;

  o = o || Object.create( null );

  _.routineOptions( watcherWaitForExit, o );

  let namespacesToCheck;

  if( o.waitForAllNamespaces )
  namespacesToCheck = _realGlobal_._ProcessWatcherNamespaces.map( ( tools ) => tools.process );
  else
  namespacesToCheck = [ processNamespace ];

  let ready = _.Consequence();
  let timer = _.time.periodic( 100, () =>
  {

    for( let i = namespacesToCheck.length - 1; i >= 0; i-- )
    {
      let namespace = namespacesToCheck[ i ];
      if( namespace.__watcherProcessDescriptors.length === 0 )
      namespacesToCheck.splice( i, 1 );
    }

    if( namespacesToCheck.length )
    return true;

    ready.take( true );
  })

  let timeOutError = _.time.outError( o.timeOut )

  ready.orKeeping( [ timeOutError ] )

  ready.finally( ( err, arg ) =>
  {
    if( !err || err.reason !== 'time out' )
    timeOutError.error( _.dont );

    if( !err )
    return arg;

    timer.cancel();

    throw err;
  })

  /* */

  return ready;
}

watcherWaitForExit.defaults =
{
  waitForAllNamespaces : 1,
  timeOut : 5000
}


//

let _on = Self.on;
function on()
{
  if( arguments.length === 2 )
  if( Events[ arguments[ 0 ] ] )
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
// declare
// --

let Events =
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
  watcherWaitForExit
}

_.construction.extend( Self, NamespaceBlueprint );

if( Config.debug )
_.construction.extend( Self, { on } );


// --
// export
// --

// if( _realGlobal_ !== _global_ )
// return ExportTo( _realGlobal_, _global_ );

if( typeof module !== 'undefined' )
module[ 'exports' ] = _.process;

})();
