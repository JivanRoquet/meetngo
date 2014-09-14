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


meetngo.displayEvents = (events) ->

    vectorSource = new ol.source.Vector({})

    for event in events
        console.log +event.lat
        console.log +event.lng
        iconFeature = new ol.Feature({
          geometry: new ol.geom.Point(ol.proj.transform([+event.lat, +event.lng], 'EPSG:4326', 'EPSG:3857')),
          organization: event.organization,
          start_date: event.start_date,
          end_date: event.end_date,
          location: event.location,
          link: event.link,
          source: event.source,
          title: event.title
        })

        vectorSource.addFeature(iconFeature)

    iconStyle = new ol.style.Style({
        image: new ol.style.Icon(({
            anchor: [0.5, 46],
            anchorXUnits: 'fraction',
            anchorYUnits: 'pixels',
            opacity: 0.75,
            src: 'http://ol3js.org/en/master/examples/data/icon.png'
        }))
    })

    vectorLayer = new ol.layer.Vector({
      source: vectorSource,
      style: iconStyle
    })

    meetngo.vl = vectorLayer
    meetngo.map.addLayer(meetngo.vl)
