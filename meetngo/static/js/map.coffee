window.meetngo ?= {}


$(document).ready ->

    pixelRatio = ol.has.DEVICE_PIXEL_RATIO

    map = new ol.Map({
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

    vectorLayer = new ol.layer.Vector("Overlay")


meetngo.displayEvents = (events) ->
    console.log "work in progress"
