import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  }

  initialize() {
    this.map = null
  }

  connect() {
    console.log("Map controller connected")
    this.initializeMap()
  }

  disconnect() {
    console.log("Map controller disconnected")
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  initializeMap() {
    console.log("Initializing map with markers:", this.markersValue)
    if (this.map) {
      this.map.remove()
    }

    mapboxgl.accessToken = this.apiKeyValue

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12",
      zoom: 1 // Ajout d'un zoom par défaut
    })

    this.map.on('load', () => {
      console.log("Map loaded, adding markers and routes")
      this.#addMarkersToMap()
      this.#addRouteToMap()
      this.#fitMapToMarkers()
    })
  }

  markersValueChanged() {
    console.log("Markers value changed:", this.markersValue)
    if (this.map) {
      this.initializeMap()
    }
  }

  #addMarkersToMap() {
    const icons = { 
      origin: '🚩',
      destination: '🏁',
      step: '📍'
    }

    if (!this.markersValue || this.markersValue.length === 0) {
      console.log("No markers to add")
      return
    }

    console.log("Adding markers:", this.markersValue)
    this.markersValue.forEach((marker) => {
      const el = document.createElement('div')
      el.style.fontSize = '30px'
      el.innerHTML = icons[marker.type]
      
      new mapboxgl.Marker({ element: el })
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map)
    })
  }

  #addRouteToMap() {
    // Trouver le dernier marqueur avec des coordonnées de route
    const markerWithRoute = this.markersValue.findLast(marker => 
      marker.route_coordinates && marker.route_coordinates.length >= 2
    );

    if (!markerWithRoute) return;

    const color = '#FF0000'; // Rouge pour l'itinéraire
    const sourceId = 'active-route';
    const layerId = 'active-route-layer';

    // Supprimer l'ancienne route si elle existe
    if (this.map.getSource(sourceId)) {
      this.map.removeLayer(layerId);
      this.map.removeSource(sourceId);
    }

    this.map.addSource(sourceId, {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: markerWithRoute.route_coordinates
        }
      }
    });

    this.map.addLayer({
      id: layerId,
      type: 'line',
      source: sourceId,
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': color,
        'line-width': 3
      }
    });
  }

  #fitMapToMarkers() {
    if (!this.markersValue || this.markersValue.length === 0) {
      console.log("No markers to fit map to")
      return
    }

    const bounds = new mapboxgl.LngLatBounds()
    this.markersValue.forEach((marker) => {
      bounds.extend([marker.lng, marker.lat])
    })

    console.log("Fitting map to bounds:", bounds)
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15, duration: 500 })
  }
}
