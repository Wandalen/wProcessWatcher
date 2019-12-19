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
 * @function watchMaking
 * @memberof module:Tools/base/ProcessWatcher.Tools( module::ProcessWatcher )
 */

function watchMaking( o )
{ 
  _.assert( arguments.length === 1 );
  _.routineOptions( watchMaking, arguments );
  _.assert( _.routineIs( o.onBegin ) || _.routineIs( o.onEnd ), 'Routine expects both {o.onBegin} and {o.onEnd} handlers.' )
  
  if( !ChildProcess )
  {
    ChildProcess = require( 'child_process' );
    
    if( _.process._watcher === null )
    {
      _.process._watcher = Object.create( null );
      _.process._watcher.onBegin = [];
      _.process._watcher.onEnd = [];
    }
    
    patch( 'spawn' );
    patch( 'fork' );
    patch( 'execFile' );
    patchSync( 'spawnSync' )
    patchSync( 'execFileSync' )
  }
  
  if( o.onBegin )
  _.arrayAppendOnce( _.process._watcher.onBegin, o.onBegin )
  if( o.onEnd )
  _.arrayAppendOnce( _.process._watcher.onEnd, o.onEnd )
  
  let result = _.mapExtend( null, o );
  result.unwatch = _.routineJoin( _.process, unwatchMaking, [{ onBegin : o.onBegin, onEnd : o.onEnd }] );
  
  return result;
  
  /*  */
  
  function patch( routine )
  { 
    let _routine = _.strPrependOnce( routine, '_' );
    
    _.assert( _.routineIs( ChildProcess[ routine ] ) );
    _.assert( !_.routineIs( ChildProcess[ _routine ] ) );
    
    let original = ChildProcess[ _routine ] = ChildProcess[ routine ];
    
    ChildProcess[ routine ] = function()
    { 
      
      let childProcess = original.apply( ChildProcess, arguments );
      let procedure = _.procedure.begin({ _name : 'PID:' + childProcess.pid, /* qqq _object : childProcess */ });
      let o = 
      {
        arguments : Array.prototype.slice.call( arguments ),
        process : childProcess
      }
      _.each( _.process._watcher.onBegin, onBegin => onBegin( o ) );
      childProcess.on( 'close', () => 
      {  
        procedure.end();
        _.each( _.process._watcher.onEnd, onEnd => onEnd( o ) );
      });
      return childProcess;
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
      let o = 
      {
        arguments : Array.prototype.slice.call( arguments ),
        process : null
      }
      let procedure = _.procedure.begin({});
      _.each( _.process._watcher.onBegin, onBegin => onBegin( o ) );
      o.returned = original.apply( ChildProcess, arguments );
      procedure.end();
      _.each( _.process._watcher.onEnd, onEnd => onEnd( o ) );
      return o.returned;
    }
  }
}

watchMaking.defaults = Object.create( null );
watchMaking.defaults.onBegin = null;
watchMaking.defaults.onEnd = null;

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
 * @function watchMaking
 * @memberof module:Tools/base/ProcessWatcher.Tools( module::ProcessWatcher )
 */

function unwatchMaking( o )
{ 
  if( !o )
  o = Object.create( null );
  
  _.routineOptions( unwatchMaking, arguments );
  
  if( !_.process._watcher )
  return false;
  
  let onBegin = _.process._watcher.onBegin;
  let onEnd = _.process._watcher.onEnd;
  
  if( !o.onBegin && !o.onEnd )
  { 
    _.arrayEmpty( onBegin );
    _.arrayEmpty( onEnd );
  }
  else
  {
    if( o.onBegin )
    _.arrayRemoveElement( onBegin,o.onBegin );
    if( o.onEnd )
    _.arrayRemoveElement( onEnd,o.onEnd );
  }
  
  if( ChildProcess )
  if( !onBegin.length && !onEnd.length )
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

unwatchMaking.defaults = Object.create( null );
unwatchMaking.defaults.onBegin = null;
unwatchMaking.defaults.onEnd = null;

//

function watcherIsAlive( watcher )
{
  _.assert( arguments.length === 1 )
  _.assert( _.objectIs( watcher ) );
  _.assert( _.routineIs( watcher.onBegin ) );
  _.assert( _.routineIs( watcher.onEnd ) );
  _.assert( _.routineIs( watcher.unwatch ) );
  
  if( !_.process._watcher )
  return false;
  
  _.assert( _.arrayIs( _.process._watcher.onBegin ) );
  _.assert( _.arrayIs( _.process._watcher.onEnd ) );
  
  if( _.arrayHas( _.process._watcher.onBegin, watcher.onBegin ) )
  if( _.arrayHas( _.process._watcher.onEnd, watcher.onEnd ) )
  return true;
  
  return false;
}

//

// --
// declare
// --

let Fields =
{
  _watcher : null,
}

let Routines =
{ 
  watchMaking,
  unwatchMaking,
  watcherIsAlive,
}

_.mapExtend( Self, Fields );
_.mapExtend( Self, Routines );

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
