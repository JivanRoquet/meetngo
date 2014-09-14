window.meetngo ?= {}


$(document).ready ->

    pixelRatio = ol.has.DEVICE_PIXEL_RATIO

    meetngo.map = new ol.Map({
        target: 'map_main',
        layers: [
            new ol.layer.Tile({
                source: new ol.source.OSM()
            })
        ],
        view : new ol.View({
            center: ol.proj.transform([2.34968, 48.8677594], 'EPSG:4326', 'EPSG:3857'),
            zoom: 16
        })
    })

    meetngo.displayEvents(meetngo.events)

    $("button#search").on "click": ->
        meetngo.getEvents()


meetngo.displayEvents = (events) ->

    vectorSource = new ol.source.Vector({})

    for event in events
        if event.lat and event.lng
            try
                console.log +event.lat
                console.log +event.lng
                iconFeature = new ol.Feature({
                  geometry: new ol.geom.Point(ol.proj.transform([+event.lng, +event.lat], 'EPSG:4326', 'EPSG:3857')),
                  organization: event.organization,
                  start_date: event.start_date,
                  end_date: event.end_date,
                  location: event.location,
                  link: event.link,
                  source: event.source,
                  title: event.title
                })

                vectorSource.addFeature(iconFeature)

            catch error
                console.log error


    iconStyle = new ol.style.Style({
        image: new ol.style.Icon(({
            anchor: [0.5, 46],
            anchorXUnits: 'fraction',
            anchorYUnits: 'pixels',
            opacity: 0.75,
            src: 'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xap1/t1.0-1/p24x24/10502110_10152533727887458_3672114636413599601_n.png'
        }))
    })

    vectorLayer = new ol.layer.Vector({
      source: vectorSource,
      style: iconStyle
    })

    if meetngo.vl
        meetngo.map.removeLayer(meetngo.vl)

    meetngo.vl = vectorLayer
    meetngo.map.addLayer(meetngo.vl)


meetngo.getEvents = ->

    who = $('input[name=organization]').val()
    when_ = $('input[name=date]').val()

    if who == ""
        who = null
    if when_ == ""
        when_ = null

    events = meetngo.events

    #zone
    eventLentgh = events.length

    #(new Date(val123).getTime())
    result = []
    startDate = null
    endDate = null
    y = 0 #Loop event

    while y < eventLentgh
        if events[y].organization is who or who is null #If event organisation is equal or not set
          startDate = events[y].start_date
          startDate = startDate[0] + startDate[1] + "/" + startDate[2] + startDate[3] + "/" + startDate[4] + startDate[5] + startDate[6] + startDate[7]
          endDate = events[y].end_date
          endDate = endDate[0] + endDate[1] + "/" + endDate[2] + endDate[3] + "/" + endDate[4] + endDate[5] + endDate[6] + endDate[7]

          #If event date is not set OR when date between start and end
          if when_ is null
              result.push events[y]
          else
              start = new Date(startDate).getTime()
              end = new Date(endDate).getTime()
              middle = new Date(when_).getTime()
              if middle >= start and middle <= end
                  result.push events[y]
        y++

    console.log result
    console.log result.length

    meetngo.map.removeLayer(1)
    meetngo.displayEvents(result)
