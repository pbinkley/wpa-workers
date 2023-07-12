---
permalink: /assets/map.js
---

  var map = new L.Map("mapid", {
      center: new L.LatLng(37.7, -122.4),
      zoom: 12
  });
  map.attributionControl.addAttribution('Map tiles by <a href="http://stamen.com">Stamen Design</a>, under <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a>. Data by <a href="http://openstreetmap.org">OpenStreetMap</a>, under <a href="http://www.openstreetmap.org/copyright">ODbL</a>.');
  map.addLayer(new L.StamenTileLayer("toner", {
                        detectRetina: true
                    }))

  var myStyle = {
    "color": "#ff7800",
    "weight": 5,
    "opacity": 0.65
  };
  
  var holcColor = {
    "A": "#008000",
    "B": "#0000FF",
    "C": "#FFFF00",
    "D": "#FF0000"
  }

  function newIcon(color) {
    return new L.Icon({
      iconUrl: '{{ site.baseurl }}/assets/img/marker-icon-' + color + '.png',
      shadowUrl: '{{ site.baseurl }}/assets/img/marker-shadow.png',
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });
  }
  
  var icons = {
    "A": newIcon("green"),
    "B": newIcon("blue"),
    "C": newIcon("gold"),
    "D": newIcon("red"),
    "": newIcon("grey")
  }
  
  var highlightedLayer = null;
  var layerIndex = {}
  
  $.getJSON("{{ site.baseurl }}/assets/OHCleveland1939.geojson", function(data) {
    holc_layer = L.geoJson(data, {
      style: function(feature) {
        return {
          fillColor: holcColor[feature.properties.holc_grade],
          fillOpacity: 0.2,
          opacity: 1,
          weight: 1,
          color: 'grey'
        }
      },
      onEachFeature: function(feature, layer) {
        layerIndex[layer.feature.properties.holc_id] = layer;
        layer.on('click', function (e) {
          window.location.href = "{{ site.baseurl }}/sections/" + layer.feature.properties.holc_id + "/";
        });
      }
    }).addTo(map);
    if (typeof section_id === 'undefined') {
      map.fitBounds(holc_layer.getBounds());
    } else {
      map.fitBounds(layerIndex[section_id].getBounds());
      // lock the centre of the map
      map.dragging.disable();
      map.options.scrollWheelZoom = "center";
      // highlight this section
      layerIndex[section_id].setStyle({fillOpacity: 0.5}); 
      // set minimum zoom
      map.options.minZoom = 12;
    }
  });

  {% for worker in site.data.workers %}
    {% if worker.longitude %}
      {% assign holc_id = worker.holc_id %}
      {% assign holc = site.data.holc | where: "id", holc_id | first %}
  L.marker([{{ worker.latitude }}, {{ worker.longitude }}], {icon: icons["{{ worker.holc_id | slice: 0 }}"]})
    .bindPopup(
      "<b>{{ worker.id }}. {{ worker.signature }}</b><br>{{ worker.sex_9 }}, " + 
      "{{ worker.race_10 }}, {{ worker.age_11 | floor }}<br>" + 
      "Occupation: \"{{ worker.occupation_28 }}\"<br>Industry: \"{{ worker.industry_29 }}\"<br>" + 
      "<b>{{ holc_id }}: {{ holc.name }}</b>")
    .addTo(map);
    {% endif %}
  {% endfor %}
