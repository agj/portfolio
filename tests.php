<?php

error_reporting(E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_RECOVERABLE_ERROR | E_DEPRECATED | E_WARNING);
//error_reporting(E_ALL);

include 'php/lambelo.php';
include 'php/spyc.php';
include 'php/classes.php';
include 'php/parser.php';

$replace = L::curry(function ($match, $replacement, $string) {
	return preg_replace($match, $replacement, $string);
});
$toLang = $replace('/.*\/([^\/]+).yaml/', '$1');


$settings = Spyc::YAMLLoad('data/settings.yaml');

$workslist = L::map(basename, glob('data/works/*', GLOB_ONLYDIR));

$test = L::foldOn($workslist, array(), function ($acc, $name) use ($toLang) {
	$langs = L::map($toLang, glob("data/works/$name/*.yaml"));
	$acc[$name] = L::foldOn($langs, array(), function ($acc, $lang) use ($name) {
		$acc[$lang] = Spyc::YAMLLoad("data/works/$name/$lang.yaml");
		return $acc;
	});
	return $acc;
});

var_export($test);
