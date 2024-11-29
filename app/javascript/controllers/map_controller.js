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
    this.markersValue.forEach((marker) => {
      if (!marker.route_coordinates) return;

      const routeId = marker.route_id;
      // Générer une couleur unique basée sur l'ID de l'itinéraire
      const colors = [
        '#FF0000', // Rouge
        '#00FF00', // Vert
        '#0000FF', // Bleu
        '#FFA500', // Orange
        '#800080', // Violet
        '#008080', // Turquoise
        '#FF69B4', // Rose
        '#4B0082', // Indigo
      ];
      const color = colors[routeId % colors.length];

      this.map.addSource(`route-${routeId}`, {
        type: 'geojson',
        data: {
          type: 'Feature',
          properties: {},
          geometry: {
            type: 'LineString',
            coordinates: marker.route_coordinates
          }
        }
      });

      this.map.addLayer({
        id: `route-${routeId}`,
        type: 'line',
        source: `route-${routeId}`,
        paint: {
          'line-color': color,
          'line-width': 3
        }
      });
    });
  }

  #fitMapToMarkers() {
    const bounds = new mapboxgl.LngLatBounds();
    this.markersValue.forEach(marker => bounds.extend([marker.lng, marker.lat]));
    this.map.fitBounds(bounds, { padding: 70, maxZoom: 15 });
  }
}
