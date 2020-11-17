---
layout: page
show_title: false
map: yes
---

 <div id="mapid"></div>
 <div id="holc_data"></div>
 
 <script>

	var map = L.map('mapid');

	L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
		maxZoom: 18,
		attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
			'<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
			'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
		id: 'mapbox/streets-v11',
		tileSize: 512,
		zoomOffset: -1
	}).addTo(map);
  
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
  
  var workers = [
    {% for worker in site.data.workers %}
      {"holc_id": "{{ worker.holc_id }}",
      "name": "{{ worker.signature }}",
      "url": "{{ worker.url }}", 
      "sex": "{{ worker.sex_9 }}", 
      "race": "{{ worker.race_10 }}",
      "age": "{{ worker.age_11 | floor }}", 
      "occupation": "{{ worker.occupation_28 }}",
      "industry": "{{ worker.industry_29 }}"      
    }{% if forloop.last %}{% else %},{% endif %}
    {% endfor %}
  ];
  
  function workerTable(holc_id) {
    var these_workers = workers.filter(x => x.holc_id === holc_id);
    console.log(these_workers);
    if (these_workers.length == 0) {
      return "";
    } else {
      output = "<table><tr><th>Name</th><th>Sex</th><th>Race</th><th>Age</th>" +
        "<th>Occupation</th><th>Industry</th></tr>";
      
      these_workers.forEach(x => output += 
        "<tr><td><a href='" + x["url"] + "'>" + x["name"] + "</a>" +
        "</td><td>" + x["sex"] +
        "</td><td>" + x["race"] +
        "</td><td>" + x["age"] +
        "</td><td>" + x["occupation"] +
        "</td><td>" + x["industry"] +
        "</td></tr>");
        
      output += "</table>";
      return output;
    }
  }

  var highlightedLayer = null;
  
  $.getJSON("{{ site.baseurl }}/assets/OHCleveland1939.geojson", function(data) {
    holc_layer = L.geoJson(data, {
      style: function(feature) {
        return {fillColor: holcColor[feature.properties.holc_grade], fillOpacity: 0.2, opacity: 1, weight: 1, color: 'grey'}
      },
      onEachFeature: function onEachFeature(feature, layer) {

        layer.on('click', function (e) {
          // holc data: e.sourceTarget.feature.properties.area_description_data
          var holc_div = document.getElementById('holc_data');
          var holc = e.sourceTarget.feature.properties;
          var holc_data = holc.area_description_data;
          
          // display data
          // TODO: list workers in this area
          holc_div.innerHTML = "<h3>HOLC Data: " + holc.holc_id + "</h3>" +
            "<dt>Name</dt><dd>" + holc_data['9'].replace(/\ (1st|2nd|3rd|4th).*/, '') + "</dd>" + 
            "<dt>Class</dt><dd>" + holc_data['1b'] + "</dd>" +
            "<dt>Nationalities</dt><dd>" + holc_data['1c'] + "</dd>" +
            "<dt>Blacks</dt><dd>" + holc_data['1d'] + "</dd>" +
            "<dt>WPA Workers</dt><dd>" + workerTable(holc.holc_id) + "</dd>" +
            "<dt>Description</dt><dd>" + holc_data['8'] + "</dd>";

          if (highlightedLayer) {
            // unhighlight the selected layer
            highlightedLayer.setStyle( {fillOpacity: 0.2});
          }

          if (layer === highlightedLayer) {
            // clear current selection without changing bounds
            highlightedLayer = null;
            holc_div.innerHTML = "";
          }
          else {
            // highlight current selection and set bounds
            layer.setStyle({fillOpacity: 0.5}); 
            highlightedLayer = layer;
            map.fitBounds(layer.getBounds());
          }
        });
      }
    }).addTo(map);
    map.fitBounds(holc_layer.getBounds());
  });

  {% for worker in site.data.workers %}
    {% if worker.longitude %}
      {% assign holc_id = worker.holc_id %}
      {% assign holc = site.data.holc | where: "id", holc_id | first %}
	L.marker([{{ worker.latitude }}, {{ worker.longitude }}], {icon: icons["{{ worker.holc_id | slice: 0 }}"]})
    .bindPopup(
      "<b>{{ worker.signature }}</b><br>{{ worker.sex_9 }}, " + 
      "{{ worker.race_10 }}, {{ worker.age_11 | floor }}<br>" + 
      "\"{{ worker.occupation_28 }}\"<br>\"{{ worker.industry_29 }}\"<br>" + 
      "<b>{{ holc_id }}: {{ holc.name }}</b>")
    .addTo(map);
    {% endif %}
  {% endfor %}
</script>