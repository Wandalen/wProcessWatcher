( function _ProcessWatcher_s_() {

'use strict';

/**
 * 
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
let Parent = null;
let Self = function wProcessWatcher( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'ProcessWatcher';

//

function init()
{
  let self = this;

  _.workpiece.initFields( self );
  
  return self;
}

//

/**
 * @summary Watch for child process start/end.
 * @description
 * Registers provided `onBegin` and `onEnd` handlers and executes them when each child process is created/closed.
 * Each handler will receive single argument - instance of ChildProcess created by one of methods:
 *  - ChildProcess.exec
 *  - ChildProcess.execFile
 *  - ChildProcess.spawn
 *  - ChildProcess.fork
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
  let self = this;
  
  _.assert( arguments.length === 1 );
  _.routineOptions( watchMaking, arguments );
  _.assert( _.routineIs( o.onBegin ) || _.routineIs( o.onEnd ), 'Routine expects at least one handler {o.onBegin} or {o.onEnd}' )
  
  if( !ChildProcess )
  {
    ChildProcess = require( 'child_process' );
    patch( 'spawn' );
    patch( 'fork' );
    patch( 'exec' );
    patch( 'execFile' );
  }
  
  if( o.onBegin )
  _.arrayAppendOnce( self.onBegin, o.onBegin )
  if( o.onEnd )
  _.arrayAppendOnce( self.onEnd, o.onEnd )
  
  return self;
  
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
      self.processes.push( childProcess );
      self.processesById[ childProcess.pid ] = childProcess;
      _.each( self.onBegin, onBegin => onBegin( childProcess ) );
      
      childProcess.on( 'close', () => 
      {  
        procedure.end();
        _.arrayRemoveElement( self.processes, childProcess );
        delete self.processesById[ childProcess.pid ];
        _.each( self.onEnd, onEnd => onEnd( childProcess ) );
      });
      
      return childProcess;
    }
  }
}

watchMaking.defaults = Object.create( null );
watchMaking.defaults.onBegin = null;
watchMaking.defaults.onEnd = null;

//

function unwatchMaking( o )
{ 
  let self = this;
  
  if( !o )
  o = Object.create( null );
  
  _.routineOptions( unwatchMaking, arguments );
  
  if( !o.onBegin && !o.onEnd )
  { 
    _.arrayEmpty( self.onBegin );
    _.arrayEmpty( self.onEnd );
  }
  else
  {
    if( o.onBegin )
    _.arrayRemoveElement( self.onBegin,o.onBegin );
    if( o.onEnd )
    _.arrayRemoveElement( self.onEnd,o.onEnd );
  }
  
  if( ChildProcess )
  if( !self.onBegin.length && !self.onEnd.length )
  {
    unpatch( 'spawn' );
    unpatch( 'fork' );
    unpatch( 'exec' );
    unpatch( 'execFile' );
    ChildProcess = null;
  }
  
  return self;
  
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

// --
// declare
// --

let Restricts = 
{
  onBegin : _.define.own( [] ),
  onEnd : _.define.own( [] ),
  processes : _.define.own( [] ),
  processesById : _.define.own( {} )
}

let Extend =
{ 
  init, 
  
  watchMaking,
  unwatchMaking,
  
  Restricts
}

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );

_.process = _.process || Object.create( null );
_.process[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = _;

})();
