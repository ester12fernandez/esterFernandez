$(window).on('load', function () {
	if ($('#preloader').length) {
		$('#preloader').delay(1000).fadeOut('slow', function () {
			$(this).remove();
		});
	}
});
const getMap = (coords) => {
	const [latitude,longitude ] = coords;
	$('#display-region').html('<div id="map"></div>');
	try {
		const mymap = L.map('map').setView([latitude, longitude], 13);
	L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
		attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
		maxZoom: 18,
		id: 'mapbox/streets-v11',
		tileSize: 512,
		zoomOffset: -1,
		accessToken: 'pk.eyJ1IjoicGFzcWFsbHkiLCJhIjoiY2t2MXVmaHZoMDJkYzJwbngzem9pemh0ciJ9.NSWDDOUrZN0-egdnXP6ckQ'
	}).addTo(mymap);
	const circle = L.circle([latitude, longitude], {
		color: 'red',
		fillColor: '#f03',
		fillOpacity: 0.5,
		radius: 500
	}).addTo(mymap);
	const marker = L.marker([latitude, longitude]).addTo(mymap);

	$.ajax({
			url: "libs/php/gazetter.php",
			type: 'POST',
			dataType: 'json',
			data: {
					latitude,
					longitude,
			},
			success: function(result) {
					let html = '';
					console.log(result)
					marker.bindPopup(`County Code: ${result.countryCode}<br>County Name: ${result.countryName}`).openPopup();
					
			},
			error: function(jqXHR, textStatus, errorThrown) {
					console.log(errorThrown, textStatus)
			}
	}); 
	} catch (error) {
		console.log(`${error}`)
		mymap.jumpTo({ 'center': coords, 'zoom': 14 });
		mymap.setPitch(30);
	}
}

const displayEarthquakes =(array) => {
	let html = '';
	array.forEach(item=>{
		html += `<br>Date: ${item.datetime}, Depth: ${item.depth}, Magnitude: ${item.magnitude}`
	})
	return html;
}

const displayWikipediaLinks = (array) => {
	let html = '';
	array.forEach((item, i)=>{
		html += `<br><a href='${item}'>Link ${i}</a>`
	})
	return html;
}


const getMap2 =async (coords) => {
	const {lat, lng, countryInfo, earthquakes, timezone, weather, wikipediaLinks } = await coords;
	$('#preloader').delay(1000).fadeOut('slow', function () {
		$(this).remove();
	});
	$('#display-region').html('<div id="map"></div>');

	const mymap =L.map('map').setView([lat, lng], 13);
	L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}', {
		attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
		maxZoom: 18,
		id: 'mapbox/streets-v11',
		tileSize: 512,
		zoomOffset: -1,
		accessToken: 'pk.eyJ1IjoicGFzcWFsbHkiLCJhIjoiY2t2MXVmaHZoMDJkYzJwbngzem9pemh0ciJ9.NSWDDOUrZN0-egdnXP6ckQ'
	}).addTo(mymap);
	const circle =L.circle([lat, lng], {
		color: 'red',
		fillColor: '#f03',
		fillOpacity: 0.5,
		radius: 500
	}).addTo(mymap);

	const marker = L.marker([lat, lng]).addTo(mymap);
	marker.bindPopup(
		`
		<h3>Country Info</h3>
		<br>Name: ${countryInfo.countryName}
		<br>Capital: ${countryInfo.capital}
		<br>Population: ${countryInfo.population}
		<br>Currency: ${countryInfo.currency}
		<br>
		<br>
		<h3>Weather Observation</h3>
		<br>Clouds: ${weather.clouds}
		<br>Humidiy: ${weather.humidity}
		<br>Temperature: ${weather.temperature}
		<br>Wind Speed: ${weather.windSpeed}
		<br>
		<br>
		<h3>Time Zone</h3>
		<br>Sunrise: ${timezone.sunrise}
		<br>Sunrise: ${timezone.sunset}
		<br>Time: ${timezone.time}
		<br>Time Zone ID: ${timezone.timezoneId}
		<br>
		<br>
		<h3>Earthquakes</h3>
		${
			displayEarthquakes(earthquakes)
		}
		<br>
		<h3>Wikipedia Links</h3>
		${displayWikipediaLinks(wikipediaLinks)}
		`).openPopup();
}





$('select').change(function() {
		$.ajax({
			url: "libs/php/gazetter.php",
			type: 'POST',
			dataType: 'json',
			data: {
				countryCode: $('select').val(),
			},
			success: function(result) {
				getMap2(result)
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log(errorThrown)
			}
		}); 
	
	});

if ('geolocation' in navigator) {
	navigator.geolocation.getCurrentPosition((position) => {

	const { latitude, longitude } = position.coords;
		getMap([latitude, longitude]);
	});
} else {
	console.log('oops!')
}


