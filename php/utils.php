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

$getLanguage = function ($possibilities) {
	$language = strtolower($_REQUEST['lang']);
	if (in_array($language, $possibilities)) return $language;
	return null;
};

$markdownParser = new Parsedown();
$fromMarkdown = function ($text) use ($markdownParser) {
	return $markdownParser->text($text);
};
$fromYaml = function ($text) {
	return Symfony\Component\Yaml\Yaml::parse($text);
};
$frontMatterParser = new Mni\FrontYAML\Parser();
$fromFrontMatter = function ($text) use ($frontMatterParser) {
	return $frontMatterParser->parse($text);
};
