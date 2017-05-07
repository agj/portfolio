<?php

require_once 'php/lambelo.php';

$br = "\n";

$replace = L::curry(function ($match, $replacement, $string) {
	return preg_replace($match, $replacement, $string);
});

$deepMerge = function ($a, $b) use (&$deepMerge) {
	$r = $a;
	foreach ($b as $key => $value) {
		$r[$key] = isset($r[$key]) && is_array($r[$key]) && is_array($value)
 			? $deepMerge($r[$key], $value)
			: $value;
	}
	return $r;
};
