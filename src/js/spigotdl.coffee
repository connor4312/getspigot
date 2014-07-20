do ->
#########################################################################
# Tiny jQuery plugin that lets us do actions on hidden elements, so we
# can grab heights and such!
##########################################################################
$.fn.whileHidden = (action, args...) ->
    if @is ':visible'
        r = @[action](args...)
    else
        r = @show()[action](args...)
        @hide()

    return r

##########################################################################
# Fairly generic handling for animating elements in/out
##########################################################################

animate =
    whenDone: (func) ->
        setTimeout func, 1000

    animate: (attribute, $element, callback = ->) ->
        if cls = $element.attr attribute
            cls += ' animated'
            $element.addClass cls

            @whenDone ->
                $element.removeClass(cls)
                callback()
        else
            callback()

    out: ($element, callback = ->) ->
        $element.each (indexx, item) =>
            @animate 'data-animate-out', $(item), ->
                $(item).hide()

        @whenDone callback

    in: ($element, callback = ->) ->
        $element.show()
        $element.each (index, item) =>
            @animate 'data-animate-in', $(item)

        @whenDone callback

##########################################################################
# Scripts specific to the index download page
##########################################################################

if $('.download-landing').length then do ->

    computeHeight = ->
        height = 0
        $content = $('.download-content > *')
        for i in $content
            height = Math.max $(i).whileHidden('height'), height

        $('.download-content').css 'min-height', height

    $(window).on 'resize load', computeHeight

$('.download-box-link').on 'click', ->
    dl = $(@).attr 'data-link'
    $frame = $('<iframe />').attr('src', dl).css 'display', 'none'

    animate.animate 'data-animate-download', $(@)
    $('body').append $frame

##########################################################################
# Slider toggles
##########################################################################

$('.slider-toggle').each ->
    $this    = $ @
    $focuser = $ '.focuser', $this
    items    = []
    selected = -1
    active   = false

    selectItem = (item) ->
        if active or item.$el?.is selected
            return

        $focuser.css
            left: item.offset
            width: item.width

        for i in items
            if not i.$el.is item.$el
                i.$el.removeClass 'active'
                animate.out i.$elements

        active = true
        selected = item.$el

        item.$el.addClass 'active'
        animate.in item.$elements, -> active = false

    computeItems = ->
        items = []
        $('li', $this).each ->
            $el     = $ @
            $elements = $ '[data-toggle="' + $el.attr('data-content') + '"]'
            data =
                $el: $el
                width: $el.outerWidth()
                offset: $el.position().left
                $elements: $elements

            $el.unbind('click')
            items.push data
            $el.on 'click', -> selectItem data

    i.$elements.hide() for i in items

    $(window).on 'load resize', computeItems
    $(window).on 'load', -> selectItem items[0]

##########################################################################
# Click-to-copy elements
##########################################################################

if window.ZeroClipboard then do ->

    handlers =
        md5copied: -> @html 'Copied!'
        inputCopied: ->
            $input  = $ 'input', @
            oldVal = $input.val()

            $input.val 'Copied!'
            @addClass 'copied'

            setTimeout =>
                @removeClass('copied')
                $input.val oldVal
            , 3000

    client = new ZeroClipboard $('.js-copy')

    client.on 'aftercopy', (e) ->
        $el   = $ e.target
        after = $el.attr 'data-aftercopy'

        if after
            handlers[after].apply $el

##########################################################################
# Download graphs
##########################################################################

if $ '#download-chart' then do ->
    $container = $ '#download-chart'
    data       = JSON.parse $container.html()
    $chart     = $ '<canvas id="download-chart" />'

    $chart.attr 'width',  $container.parent().innerWidth()
          .attr 'height', $('.download-box-light').outerHeight() - (15 * 5)

    $container.replaceWith $chart

    labels = []
    plot   = []
    for item in data
        date = new Date(item.x * 1000)

        labels.push (date.getMonth() + 1) + '/' + date.getDate()
        plot.push item.y

    chart = new Chart($chart[0].getContext('2d')).Line
        labels: labels
        datasets: [{
            label: 'Downloads'
            fillColor: 'rgba(0, 0, 0, 0)'
            strokeColor: '#d7811e'
            pointColor: '#fff'
            pointStokeColor: '#d7811e'
            pointHighlightFill: '#d7811e'
            pointHighlightStoke: '#fff'
            data: plot
        }]
    ,
        bezierCurve: false
        scaleSteps: 3