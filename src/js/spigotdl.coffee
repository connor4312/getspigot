#########################################################################
# Tiny jQuery plugin that lets us do actions on hidden elements, so we
# can grab heights and such!
##########################################################################
$.fn.whileHidden = (action, args...) ->
    r = @show()[action](args...)
    @hide()

    return r

##########################################################################
# Fairly generic handling for animating elements in/out
##########################################################################

animate =
    animate: (attribute, $element, callback = ->) ->
        if cls = $element.attr attribute
            cls += ' animated'
            $element.addClass cls
            setTimeout ->
                $element.removeClass(cls)
                callback()
            , 1000
        else
            callback()

    out: ($element) ->
        @animate 'data-animate-out', $element, -> $element.hide()

    in: ($element) ->
        $element.show()
        @animate 'data-animate-in', $element

##########################################################################
# Slider toggles
##########################################################################

$('.slider-toggle').each ->
    $this    = $ @
    $focuser = $ '.focuser', $this
    items    = []

    selectItem = (item) ->
        $focuser.css
            left: item.offset
            width: item.width

        for i in items
            if not i.$el.is item.$el
                i.$el.removeClass 'active'
                animate.out i.$elements

        item.$el.addClass 'active'
        animate.in item.$elements

    do computeItems = ->
        items = []
        $('li', $this).each ->
            $el     = $ @
            $elements = $ '[data-toggle="' + $el.attr('data-content') + '"]'
            data =
                $el: $el
                width: $el.width()
                offset: $el.position().left
                $elements: $elements

            $el.unbind('click')
            items.push data
            $el.on 'click', -> selectItem data

    $(window).resize computeItems
    selectItem items[0]

##########################################################################
# Scripts specific to the index download page
##########################################################################

if $('.download-landing').length then do ->

    do computeHeight = ->
        height = 0
        $content = $('.download-content')
        for i in $content
            height = Math.max $(i).whileHidden('height'), height

        $content.css 'min-height', height

    $(window).resize computeHeights