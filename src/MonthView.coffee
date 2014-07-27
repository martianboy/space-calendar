{View, $} = require 'space-pen'
# moment = require 'moment-jalaali'

module.exports = class MonthView extends View
	@content: () ->
		@div class: 'days-container', =>
			for i in [1..42]
				@div class: 'sc-day'

	updateDateRange: (date) ->
		@intervalStart = date.clone().startOf('month')
		@intervalEnd = @intervalStart.clone().add(1, 'month')

		@start = @intervalStart.clone().startOf('week')

		@updateDayCells()

		return

	updateDayCells: () ->
		dayCellClass = (m) ->
			oldLang = m.lang()._abbr
			m.lang('en')

			classes = ['sc-day']
			classes.push('sc-' + m.format('ddd'))

			if +intervalStart > +m or +intervalEnd <= +m
				classes.push('sc-other-month')

			m.lang(oldLang)

			classes.join(' ')

		d = @start.clone()
		intervalStart = @intervalStart
		intervalEnd = @intervalEnd

		@children().each( (index, el) ->
			$(el)
				.removeClass()
				.addClass(dayCellClass(d))
				.text(d.format('D'))

			d.add(1, 'days')

			return
		)

		return

	initialize: (date) ->
		dayClickHandler = (e) ->
			@trigger('select', e)
			return

		@updateDateRange(date)

		@on('click', '.sc-day', dayClickHandler.bind(this))
		return

	afterAttach: (onDom) ->
		console.log(onDom)
		@parent().addClass('sc-month-view')
