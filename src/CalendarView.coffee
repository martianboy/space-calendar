{View} = require 'space-pen'
moment = require 'moment-jalaali'

MonthView = require './MonthView'
EventsView = require './EventsView'

eventSource = [
	title: 'Gholi'
	start: moment().subtract(1, 'week').startOf('day')
	end: moment().subtract(1, 'week').startOf('day').add(2, 'day')
,
	title: 'Overlapping Event'
	start: moment().subtract(1, 'week').add(1, 'day').startOf('day')
	end: moment().subtract(1, 'week').add(1, 'day').startOf('day').add(2, 'day')
,
	title: 'Hole Event!'
	start: moment().subtract(1, 'week').add(2, 'day').startOf('day')
	end: moment().subtract(1, 'week').add(2, 'day').startOf('day').add(1, 'day')
,
	title: 'AllDay event'
	start: moment().startOf('day')
	end: moment().startOf('day').add(1, 'day')
]

module.exports = class CalendarView extends View
	@content: () ->
		@div id: 'space-calendar', =>
			@subview 'view', new MonthView(moment())
			@subview 'events', new EventsView(eventSource)
