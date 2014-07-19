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

    client = new ZeroClipboard $('.js-copy')

    client.on 'aftercopy', (e) ->
        $el   = $ e.target
        after = $el.attr 'data-aftercopy'

        if after
            handlers[after].apply $el