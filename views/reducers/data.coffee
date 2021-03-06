{Immutable} = window

module.exports = (state = Immutable.List(), action) =>
  switch action.type
    when 'ADD_LOG'
      state.unshift action.log
    when 'INITIALIZE_LOGS'
      Immutable.List action.logs
    else
      state
