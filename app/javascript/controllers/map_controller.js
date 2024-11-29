import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static values = {
    apiKey: String,
    markers: Array
  }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue;

    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v12"
    });

    this.map.on('load', () => {
      this.#addMarkersToMap();
      this.#addRouteToMap();
      this.#fitMapToMarkers();
    });
  }

  #addMarkersToMap() {
    const icons = { 
      origin: '🚩',
      destination: '🏁',
      step: '📍'
    };

    this.markersValue.forEach((marker) => {
      const el = document.createElement('div');
      el.style.fontSize = '30px';
      el.innerHTML = icons[marker.type];
      
      new mapboxgl.Marker({ element: el })
        .setLngLat([marker.lng, marker.lat])
        .addTo(this.map);
    });
  }

  #addRouteToMap() {
    if (!this.markersValue[0]?.route_coordinates) return;

    this.map.addSource('route', {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: this.markersValue[0].route_coordinates
        }
      }
    });

    this.map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      paint: {
        'line-color': '#FF0000',
        'line-width': 3
      }
    });
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]));
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15 });
  }
}
