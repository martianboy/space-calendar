module.exports.isThenable = (any) ->
	if any == undefined
		return false

  try
    f = any.then
    return true if typeof f == "function"

  catch e
  	# squelch

  false
