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
	

	function get_country_isocode_and_name() {
		$decoded_data = json_decode(file_get_contents('countryBorders.geo.json'), true);
		$countries = array();
		// print_r($decoded_data);
		foreach($decoded_data['features'] as $feature) {
			$obj['countryName'] = $feature['properties']['name'];
			$obj['countryCode'] = $feature['properties']['iso_a2'];
			array_push($countries, $obj);
		}
		echo json_encode($countries);
	}


	function get_borders($countryCode) {
		$decoded_data = json_decode(file_get_contents('countryBorders.geo.json'), true);
		$coordinates = array();
		foreach($decoded_data['features'] as $feature) {
			$iso_a2 = $feature['properties']['iso_a2'];
			$polygons = array();

			if($iso_a2 == $countryCode) {
				foreach($feature['geometry'] as $geometry) {
					array_push($polygons, $geometry);
				}
				array_push($coordinates, $polygons);
			}
		}
		return $coordinates;
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

		return json_encode($combined);
	}


	
	if(isset($_REQUEST['countryCode'])) {
		$countryCode = $_REQUEST['countryCode'];
		echo combine_funcs($countryCode);
		return;
	}
	get_country_isocode_and_name();
	

?>
