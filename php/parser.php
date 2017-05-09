<?php

require_once 'php/lib/autoload.php';
require_once 'php/lambelo.php';
require_once 'php/classes.php';
require_once 'php/utils.php';

$markdown = new League\CommonMark\CommonMarkConverter();

class Parser {

	public static function parseWork($id, $yaml, $language, $general, $replacements) {
		global $deepMerge;
		global $markdown;

		$raw = $yaml['default'];
		$readMoreTranslated = true;
		if (isset($yaml[$language])) {
			$raw = $deepMerge($raw, $yaml[$language]);
			$readMoreTranslated = isset($yaml[$language]['readMore']);
		}

		if (isset($raw["hide"]) && $raw["hide"] === true)
			return null;

		$w = new Work();
		$w->id = $id;
		$w->name = $raw['name'];
		$w->type = self::findReplacement($raw['type'], $replacements['type']);
		$w->year = $raw['year'];
		$w->image = self::getImageFilename($w->id);
		$w->description = $markdown->convertToHTML($raw['description']);
		$w->category = is_array($raw['category']) ? $raw['category'] : array($raw['category']);
		$w->readMore = $raw['readMore'];

		$w->readMoreLabel = $readMoreTranslated
			? $general['readMore']
			: $general['readMoreNonTranslated'];

		if (isset($raw["links"])) {
			$links = array();
			foreach ($raw["links"] as $name => $definition) {
				$links[] = self::getLink($raw, $name, $definition, $replacements);
			}
			$w->links = $links;
		}

		return $w;
	}

	public static function getCategories($general, $language) {
		return L::mapIdxOn($general['categoryNames'], function ($name, $id) {
			$cat = new Category;
			$cat->id = $id;
			$cat->name = $name;
			return $cat;
		});
	}


	//////////////////////////////////////////

	private static function getLink($raw, $name, $definition, $replacements) {
		$link = new Link();

		$link->name = self::findReplacement($name, $replacements['links']);

		if (is_string($definition)) {
			$link->url = $definition;
			$link->popup = true;
		} else {
			$link->url = $definition['url'];
			$link->popup = (!isset($definition['popup']) || $definition['popup'] === true);
			if ($link->popup) {
				if (isset($definition['width']))	$link->width = $definition['width'];
				if (isset($definition['height']))	$link->height = $definition['height'];
				if (isset($definition['color']))	$link->color = $definition['color'];
			}
		}

		return $link;
	}

	private static function findReplacement($string, $replacements) {
		if (isset($replacements[$string])) return $replacements[$string];
		return $string;
	}

	private static function getImageFilename($id) {
		return '01.' . L::findOn(
			array('jpg', 'png', 'gif'),
			function ($ext) use ($id) { return file_exists("data/works/$id/01.$ext"); }
		);
	}

}
