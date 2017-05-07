<?php

require_once 'php/lambelo.php';
require_once 'php/classes.php';

class Parser {

	public static function parseWork($id, $yaml, $language, $general, $replacements) {
		$raw = $yaml['default'];
		$readMoreTranslated = false;
		if (isset($yaml[$language])) {
			$raw = array_merge($raw, $yaml[$language]);
			$readMoreTranslated = isset($yaml[$language]['readMore']);
		}

		if (isset($raw["hide"]) && $raw["hide"] === true)
			return null;

		$w = new Work();
		$w->id = $id;
		$w->name = $raw['name'];
		$w->type = self::findReplacement($raw['type'], $replacements['type']);
		$w->year = $raw['year'];
		$w->image = $raw['image'];
		$w->description = $raw['description'];
		$w->category = $raw['category'];
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

	public static function getLightboxString($link, $group) {
		if (!$link->popup)
			return '';

		$result = ' rel="lightbox[work-' . $group;
		if ($link->width)
			$result .= ' ' . $link->width;
		if ($link->height)
			$result .= ' ' . $link->height;
		if ($link->color)
			$result .= ' ' . $link->color;
		$result .= ']"';

		return $result;
	}

	public static function getCategories($general, $language) {
		return L::mapIdxOn($general['categoryNames'], function ($name, $id) {
			$cat = new Category;
			$cat->id = $id;
			$cat->name = $name;
			return $cat;
		});
		// $result = array();

		// foreach ($general["categoryNames"] as $id => $name) {
		// 	$cat = new Category;
		// 	$cat->id = $id;
		// 	$cat->name = $name;
		// 	$result[] = $cat;
		// }

		// return $result;
	}

	public static function getGeneralValue($yaml, $language, $prop) {
		if (self::hasDeepProperty($yaml, 'translation', $language, 'general', $prop))
			return $yaml["translation"][$language]["general"][$prop];
		return $yaml["general"][$prop];
	}


	//////////////////////////////////////////

	private static function getWorkValue($language, $rawW, $prop) {
		if (self::hasDeepProperty($rawW, 'translation', $language, $prop))
			return $rawW["translation"][$language][$prop];
		if (isset($rawW[$prop]))
			return $rawW[$prop];
		return NULL;
	}

	private static function getWorkValueExtended($yaml, $language, $rawW, $prop) {
		if (self::hasDeepProperty($rawW, 'translation', $language, $prop))
			return $rawW['translation'][$language][$prop];
		else if (self::hasDeepProperty($yaml, 'translation', $language, 'works', $prop, $rawW[$prop]))
			return $yaml['translation'][$language]['works'][$prop][$rawW[$prop]];
		return $rawW[$prop];
	}

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

	private static function hasDeepProperty() {
		$current = func_get_arg(0);
		if (!$current)
			return false;

		$len = func_num_args();
		for ($i = 1; $i < $len; $i++) {
			$arg = func_get_arg($i);
			if (!$arg)
				return false;
			if (!isset($current[$arg]))
				return false;
			$current = $current[$arg];
			if (!$current)
				return false;
		}
		return true;
	}

}
