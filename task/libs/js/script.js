$(window).on('load', function () {
	if ($('#preloader').length) {
	$('#preloader').delay(1000).fadeOut('slow', function () {
	$(this).remove();
	});
	}
	});
$('#btnRun').click(function() {

		$.ajax({
			url: "libs/php/getCountryInfo.php",
			type: 'POST',
			dataType: 'json',
			data: {
				country: $('#selCountry').val(),
				lang: $('#selLanguage').val()
			},
			success: function(result) {

				console.log(JSON.stringify(result));

				if (result.status.name == "ok") {

					$('#txtContinent').html(result['data'][0]['continent']);
					$('#txtCapital').html(result['data'][0]['capital']);
					$('#txtLanguages').html(result['data'][0]['languages']);
					$('#txtPopulation').html(result['data'][0]['population']);
					$('#txtArea').html(result['data'][0]['areaInSqKm']);

				}
			
			},
			error: function(jqXHR, textStatus, errorThrown) {
				// your error code
				console.log(errorThrown)
			}
		}); 
	
	});

	$('#countrycodeBtn').click(function() {
		$.ajax({
			url: "libs/php/getCountryInfo.php",
			type: 'POST',
			dataType: 'json',
			data: {
				lat: $('#lat').val(),
				long: $('#lng').val(),
				countryCode: 'countryCode'
			},
			success: function(result) {
				ul = `<ul>
						<li>Languages: ${result.languages}</li>
						<li>Distance: ${result.distance}</li>
						<li>Country Code: ${result.countryCode}</li>
						<li>Country Name: ${result.countryName}</li>
					</ul>`;
				$('#results').append(ul);
			
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log(errorThrown, textStatus)
			}
		}); 
	
	});

	$('#nearbyplaceBtn').click(function() {
		$.ajax({
			url: "libs/php/getCountryInfo.php",
			type: 'POST',
			dataType: 'json',
			data: {
				lat: $('#placeLat').val(),
				long: $('#placeLng').val(),
				nearbyPlace: 'nearbyPlace'
			},
			success: function(result) {
				ul = `<ul>
						<li>Ascii Name: ${result['geonames'][0].asciiName}</li>
						<li>Distance: ${result['geonames'][0].distance}</li>
						<li>Country Code: ${result['geonames'][0].countryCode}</li>
						<li>Country Name: ${result['geonames'][0].countryName}</li>
						<li>Admin Name1: ${result['geonames'][0].adminName1}</li>
					</ul>`;
				$('#results').append(ul);
			
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log(errorThrown, textStatus)
			}
		}); 
	
	});


	$('#weatherBtn').click(function() {
		$.ajax({
			url: "libs/php/getCountryInfo.php",
			type: 'POST',
			dataType: 'json',
			data: {
				south: $('#south').val(),
				north: $('#north').val(),
				east: $('#east').val(),
				west: $('#west').val(),
				weather: 'weather'
			},
			success: function(result) {
				let html = '';
				console.log(result)
				result['weatherObservations'].forEach(observation => {
					html += `
							<ul>
								<li>
									Long: ${observation.lng}
								</li>
								<li>
									Observation: ${observation.observation}
								</li>
								<li>
									Clouds: ${observation.clouds}
								</li>
								<li>
									Station Name: ${observation.stationName}
								</li>
							</ul>
						`;
				});

				$('#results').append(html);
			},
			error: function(jqXHR, textStatus, errorThrown) {
				console.log(errorThrown, textStatus)
			}
		}); 
	
	});

	
