{View, $, $$} = require 'space-pen'
{isThenable} = require './utils.coffee'
_ = require 'underscore'

module.exports = class MonthEventsView extends View
	@content: ->
		@div class: 'sc-events-container'

	initialize: (eventSource) ->
		if _.isArray(eventSource)
			@renderEvents(eventSource)
		else if isThenable(eventSource)
			eventSource.then(@renderEvents)

	renderEvents: (events) ->
		chunkClass = (chunk) ->
			classes = ['sc-chunk', 'sc-span-' + (chunk.right - chunk.left + 1)]
			if chunk.offset then classes.push 'sc-offset-' + chunk.offset
			if chunk.beginning then classes.push 'sc-chunk-start'
			if chunk.end then classes.push 'sc-chunk-end'

			classes.join(' ')

		consoleTableEvents = (events) ->
			console.table _.map events, (ev) ->
				title: ev.title
				start: ev.start.format 'ddd, LL'
				end: ev.end.format 'ddd, LL'

			return

		toCoordinateGrid = (ev) ->
			startCol = ev.start.weekday()
			startRow = Math.floor(ev.start.diff(ev.start.clone().startOf('month').startOf('week'), 'days') / 7)
			span = ev.end.diff(ev.start, 'days')
			endCol = (7 + ev.end.weekday() - 1) % 7
			chunksCount = Math.floor((startCol + span - 1) / 7) + 1

			chunks = []

			while span > 0
				chunks.push
					left: startCol
					right: if span < 7 then Math.min(6, endCol) else 6
					row: startRow++
					title: ev.title

				span -= 7 - startCol
				startCol = 0

			_.first(chunks).beginning = true
			_.last(chunks).end = true

			chunks

		checkOverlap = (chunk1, chunk2) ->
			return if chunk2.left > chunk1.left then chunk1.right >= chunk2.left else chunk2.right >= chunk1.left

		overlapsWith = (chunk) ->
			return checkOverlap.bind(null, chunk)

		fixChunkOffset = (offset, chunk) ->
			chunk.offset = chunk.left - offset + 1
			offset + chunk.right - chunk.left + 1

		toSubrows = (row) ->
			subrows = []

			while row.length > 0
				chunk = _.first(row)
				[row, nonOverlappingChunks] = _.partition(_.without(row, chunk), overlapsWith(chunk))
				subrow = [chunk].concat(nonOverlappingChunks)

				_.reduce subrow, fixChunkOffset, 0

				subrows.push(subrow)

			subrows

		renderRow = (subrows) ->
			@ol class: 'sc-row-' + subrows[0][0].row, =>
				_.map subrows, renderSubrow.bind(this)

		renderSubrow = (subrow) ->
			@li =>
				_.map subrow, renderChunk.bind(this)

		renderChunk = (chunk) ->
			@div class: chunkClass(chunk), draggable: true, =>
				@text chunk.title

		@append $$ ->
			_.chain(events)
				.map toCoordinateGrid
				.flatten true
				.groupBy 'row'
				.map toSubrows
				.map renderRow.bind(this)
				.value()

	afterAttach: (onDom) ->
		dragStart = (e) ->
			console.log(e)

		document
			.querySelectorAll('.sc-chunk')
			.addEventListener('dragstart', dragStart)