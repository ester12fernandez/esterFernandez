<?php

	ini_set('display_errors', 'On');
	error_reporting(E_ALL);
	header('Content-Type: application/json; charset=UTF-8');

	$executionStartTime = microtime(true);
	
	function get_decoded_json_data($url){
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

		curl_setopt($ch, CURLOPT_URL,$url);
		$result=curl_exec($ch);
		curl_close($ch);

		return json_decode($result, true);
	}

	function get_position($iso_code){
		$url = 'https://api.worldbank.org/v2/country/'.$iso_code.'?format=json';

		$decode = get_decoded_json_data($url);
		$position = array();
		foreach($decode[1] as $val){
			array_push($position,$val['latitude']);
			array_push($position,$val['longitude']);
		}
		return $position;
	}

	function get_weather($lat, $long) {
		$url = 'http://api.geonames.org/findNearByWeatherJSON?lat='.$lat.'&lng='.$long.'&username=flightltd';
		$decode = get_decoded_json_data($url);
		
		return $decode['weatherObservation'];
	}


	function get_country_info($iso_code) {
		$url = 'http://api.geonames.org/countryInfoJSON?country='.$iso_code.'&username=flightltd';
		
		$decode = get_decoded_json_data($url);
		// print_r($decode);
		$country['countryName'] = $decode['geonames'][0]['countryName'];
		$country['capital'] = $decode['geonames'][0]['capital'];
		$country['population'] = $decode['geonames'][0]['population'];
		$country['currency'] = $decode['geonames'][0]['currencyCode'];
		$country['east'] = $decode['geonames'][0]['east'];
		$country['west'] = $decode['geonames'][0]['west'];
		$country['south'] = $decode['geonames'][0]['south'];
		$country['north'] = $decode['geonames'][0]['north'];
		return $country;
	}
	
	function get_subdivision($lat, $lng) {
		$url = 'http://api.geonames.org/countrySubdivisionJSON?lat='.$lat.'&lng='.$lng.'&username=flightltd';
		
		$decode = get_decoded_json_data($url);

		$subdivision['codes']['code'] = $decode['codes'][0]['code'];
		$subdivision['codes']['level'] = $decode['codes'][0]['level'];
		$subdivision['codes']['type'] = $decode['codes'][0]['type'];
		$subdivision['adminCode'] = $decode['adminCode1'];
		$subdivision['distance'] = $decode['distance'];
		$subdivision['countryCode'] = $decode['countryCode'];
		$subdivision['adminName'] = $decode['adminName1'];
		return $subdivision;
	}
	


	function get_timezone($lat, $lng) {
		$url = 'http://api.geonames.org/timezoneJSON?lat='.$lat.'&lng='.$lng.'&username=flightltd';
		$decode = get_decoded_json_data($url);

		$timezone['sunrise'] = $decode['sunrise'];
		$timezone['sunset'] = $decode['sunset'];
		$timezone['timezoneId'] = $decode['timezoneId'];
		$timezone['time'] = $decode['time'];
		return $timezone;
	}
	


	function get_earthquakes_info($north, $south, $east, $west) {
		$url = 'http://api.geonames.org/earthquakesJSON?north='.$north.'&south='.$south.'&east='.$east.'&west='.$west.'&username=flightltd';
		
		$decode = get_decoded_json_data($url);
		return $decode['earthquakes'];
	}
	
	
	function get_wikipedia_links($lat, $lng){
		$url = 'http://api.geonames.org/findNearbyWikipediaJSON?lat=47&lng=9&username=flightltd';
		$decode = get_decoded_json_data($url);

		$links = array();
		foreach($decode['geonames'] as $array) {
			array_push($links, $array['wikipediaUrl']);
		}
		return $links;
	}
	
	
	function get_country_isocodes_and_currency() {
		$decoded_data = json_decode(file_get_contents('countryBorders.geo.json'), true);
		$countries = array();
		foreach($decoded_data['features'] as $feature) {
			$obj['countryName'] = $feature['properties']['name'];
			$obj['countryCode'] = $feature['properties']['iso_a2'];
			array_push($countries, $obj);
		}

		$decoded_currency = get_decoded_json_data('https://openexchangerates.org/api/currencies.json');
		$info['countries']['codes'] = $countries;
		$info['countries']['currency'] = $decoded_currency;
		echo json_encode($info);
	}


	function get_borders($countryCode) {
		$decoded_data = json_decode(file_get_contents('countryBorders.geo.json'), true);
		$coordinates = array();
		foreach($decoded_data['features'] as $feature) {
			$iso_a2 = $feature['properties']['iso_a2'];

			if($iso_a2 == $countryCode) {
				return $feature;
			}
		}
	}

	function weather_forecast($lat, $lng){
		$url = 'https://api.openweathermap.org/data/2.5/onecall?lat='.$lat.'&lon='.$lng.'&appid=6bedfd9080f6afabcd9916c2f08cd514';
		$decoded_data = get_decoded_json_data($url);

		$forecast['hourly']['clouds'] = $decoded_data['hourly'][0]['weather'][0]['main'];
		$forecast['hourly']['windSpeed'] = $decoded_data['hourly'][0]['wind_speed'];
		$forecast['hourly']['humidity'] = $decoded_data['hourly'][0]['humidity'];
		$forecast['hourly']['temperature'] = $decoded_data['hourly'][0]['temp'];
		return $forecast;
	}



	function get_news($iso_code) {
		$url = 'https://newsapi.org/v2/top-headlines?country='.$iso_code.'&apiKey=25a5e95332b04eca84a292bf43720101';
		
		$decoded_data = get_decoded_json_data($url);
		return $decoded_data['articles'];
	}

	function combine_funcs($iso_code){
		$lat = get_position($iso_code)[0];
		$lng = get_position($iso_code)[1];
		
		$combined['lat'] = $lat;
		$combined['lng'] = $lng;
		$combined['weather']['clouds'] = get_weather($lat, $lng)['clouds'];
		$combined['weather']['humidity'] = get_weather($lat, $lng)['humidity'];
		$combined['weather']['temperature'] = get_weather($lat, $lng)['temperature'];
		$combined['weather']['windSpeed'] = get_weather($lat, $lng)['windSpeed'];
		$combined['countryInfo'] = get_country_info($iso_code);
		// $combined['subdivision'] = get_subdivision($lat, $lng);
		$combined['timezone'] = get_timezone($lat, $lng);
		$combined['earthquakes'] = get_earthquakes_info(
			get_country_info($iso_code)['north'], 
			get_country_info($iso_code)['south'], 
			get_country_info($iso_code)['east'], 
			get_country_info($iso_code)['west']
		);
		$combined['wikipediaLinks'] = get_wikipedia_links($lat, $lng);
		$combined['borders'] = get_borders($iso_code);
		$combined['weather_forecast'] = weather_forecast($lat, $lng);
		$combined['latest_news'] = get_news($iso_code);

		return json_encode($combined);
	}



	if(isset($_REQUEST['from']) && isset($_REQUEST['to']) && isset($_REQUEST['value'])) {
		$from = $_REQUEST['from'];
		$to = $_REQUEST['to'];
		$value = $_REQUEST['value'];
		echo json_encode(convert_currency($from,$to,$value));
		return;
	}
	if(isset($_REQUEST['countryCode'])) {
		$countryCode = $_REQUEST['countryCode'];
		echo combine_funcs($countryCode);
		return;
	}
	get_country_isocodes_and_currency();
	

?>
