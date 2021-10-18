<?php

	// remove for production

	ini_set('display_errors', 'On');
	error_reporting(E_ALL);
	header('Content-Type: application/json; charset=UTF-8');

	$executionStartTime = microtime(true);
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

	$url = '';

	if(isset($_REQUEST['countryCode'])) {
		$url = 'http://api.geonames.org/countryCodeJSON?formatted=true&lat='. $_REQUEST['lat']. '&lng='. $_REQUEST['long'] .'&username=flightltd&style=full';
	} elseif(isset($_REQUEST['nearbyPlace'])) {
		$url = 'http://api.geonames.org/findNearbyPlaceNameJSON?formatted=true&lat='. $_REQUEST['lat']. '&lng='. $_REQUEST['long'] .'&username=flightltd&style=full';
	} elseif(isset($_REQUEST['weather'])) {
		$url = 'http://api.geonames.org/weatherJSON?formatted=true&north='.$_REQUEST['north'].'&south='.$_REQUEST['south'].'&east='.$_REQUEST['east'].'&west='.$_REQUEST['west'].'&username=flightltd&style=full';
	} else {
		$url='http://api.geonames.org/countryInfoJSON?formatted=true&lang=' . $_REQUEST['lang'] . '&country=' . $_REQUEST['country'] . '&username=flightltd&style=full';

		curl_setopt($ch, CURLOPT_URL,$url);

		$result=curl_exec($ch);

		curl_close($ch);

		$decode = json_decode($result,true);	

		$output['status']['code'] = "200";
		$output['status']['name'] = "ok";
		$output['status']['description'] = "success";
		$output['status']['returnedIn'] = intval((microtime(true) - $executionStartTime) * 1000) . " ms";
		$output['data'] = $decode['geonames'];
		
		echo json_encode($output); 
		return;
	}

	
	curl_setopt($ch, CURLOPT_URL,$url);

	$result=curl_exec($ch);

	curl_close($ch);

	$decode = json_decode($result,true);	

	echo json_encode($decode); 
	
?>
