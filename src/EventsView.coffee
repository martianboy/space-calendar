{View, $, $$} = require 'space-pen'
{isThenable} = require './utils'
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

		getEventChunks = (ev) ->
			startCol = ev.start.weekday()
			startRow = Math.floor(ev.start.diff(ev.start.clone().startOf('month').startOf('week'), 'days') / 7)
			span = ev.end.diff(ev.start, 'days')
			endCol = (7 + ev.end.weekday() - 1) % 7
			chunksCount = Math.floor((startCol + span - 1) / 7) + 1

			# console.table [
			# 	title: ev.title
			# 	start: ev.start.format 'ddd, LL'
			# 	end: ev.end.format 'ddd, LL'
			# 	startCol: startCol
			# 	endCol: endCol
			# 	span: span
			# 	chunksCount: chunksCount
			# ]

			if chunksCount == 1
				chunks = [
					left: startCol
					right: endCol
					row: startRow
					ev: ev
					beginning: true
					end: true
				]
			else
				chunks = [
					left: startCol
					right: 6
					row: startRow++
					ev: ev
					beginning: true
					end: false
				]
				i = 1
				while i++ < chunksCount - 1
					chunks.push(
						left: 0
						right: 6
						row: startRow++
						ev: ev
						beginning: false
						end: false
					)
				chunks.push(
					left: 0
					right: endCol
					row: startRow
					ev: ev
					beginning: false
					end: true
				)

		 	chunks

		transformIntoRows = (chunks) ->
			checkOverlap = (chunk1, chunk2) ->
				return if chunk2.left > chunk1.left then chunk1.right >= chunk2.left else chunk2.right >= chunk1.left

			overlapsWith = (chunk) ->
				return checkOverlap.bind(null, chunk)

			fixChunkOffset = (offset, chunk) ->
				chunk.offset = chunk.left - offset + 1
				offset + chunk.right - chunk.left + 1

			rows = _.groupBy(chunks, 'row')

			_.map rows, (row) ->
				subrows = []

				while row.length > 0
					chunk = _.first(row)
					[row, nonOverlappingChunks] = _.partition(_.without(row, chunk), overlapsWith(chunk))
					subrow = [chunk].concat(nonOverlappingChunks)

					_.reduce subrow, fixChunkOffset, 0

					subrows.push(subrow)

				subrows

		chunks = _.chain(events)
			.map getEventChunks
			.flatten true
			.value()

		rows = transformIntoRows(chunks)

		@append $$ ->
			_.map rows, (subrows) =>
				@ol class: 'sc-row-' + subrows[0][0].row, =>
					_.map subrows, (subrow) =>
						@li =>
							_.map subrow, (chunk) =>
								@div class: chunkClass(chunk), draggable: true, =>
									@text chunk.ev.title

	afterAttach: (onDom) ->
		dragStart = (e) ->
			console.log(e)

		document
			.querySelectorAll('.sc-chunk')
			.addEventListener('dragstart', dragStart)