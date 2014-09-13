window.meetngo ?= {}


$(document).ready ->

    pixelRatio = ol.has.DEVICE_PIXEL_RATIO

    meetngo.map = new ol.Map({
        target: 'map_main',
        layers: [
            new ol.layer.Tile({
                source: new ol.source.OSM({}),
            })
        ],
        view : new ol.View({
            center: ol.proj.transform([2.34968, 48.8677594], 'EPSG:4326', 'EPSG:3857'),
            zoom: 16
        })
    })

    meetngo.displayEvents('hey')


meetngo.displayEvents = (events) ->

    console.log 1
    meetngo.events = []

    console.log 2
    event = new ol.Feature({
      geometry: new ol.geom.Point(ol.proj.transform([2.34968, 48.8677594], 'EPSG:4326', 'EPSG:3857')),
      name: 'My Event',
    })

    console.log 3
    meetngo.events.push(event)

    console.log 4
    vectorSource = new ol.source.Vector({
      features: meetngo.events
    })

    console.log 5
    iconStyle = new ol.style.Style(({
        anchor: [0.5, 46],
        anchorXUnits: 'fraction',
        anchorYUnits: 'pixels',
        opacity: 0.75,
        src: 'http://ol3js.org/en/master/examples/data/icon.png'
    }))

    console.log 6
    vectorLayer = new ol.layer.Vector({
      source: vectorSource,
      style: iconStyle
    })

    meetngo.map.addLayer(vectorLayer)
