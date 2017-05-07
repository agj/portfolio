<?php

class Parser {

	public static function parseWork($id, $yaml, $language, $general) {
		$raw = $yaml['default'];
		if (isset($yaml[$language]))
			$raw = array_merge($raw, $yaml[$language]);

		if (isset($raw["hide"]) && $raw["hide"] === true)
			return null;

		$w = new Work();
		$w->id = $id;
		$w->name = $raw['name'];
		$w->type = $raw['type'];
		$w->year = $raw['year'];
		$w->image = $raw['image'];
		$w->description = $raw['description'];
		$w->category = $raw['category'];
		$w->readMore = $raw['readMore'];

		$w->readMoreLabel = $general['general']['readMore'];
		// $w->readMoreLabel = (!$language || $w->readMore)
		// 	? $general['general']['readMore']
		// 	: $general['general']['readMoreNonTranslated'];

		// if ($translation) {
		// 	if (self::hasDeepProperty($raw, 'translation', $language, 'readMore'))
		// 		$w->readMoreLabel = $translation["general"]["readMore"];
		// 	else
		// 		$w->readMoreLabel = $translation["general"]["readMoreNonTranslated"];
		// } else {
		// 	$w->readMoreLabel = $yaml["general"]["readMore"];
		// }

		if (isset($raw["links"])) {
			$links = array();
			foreach ($raw["links"] as $name => $definition) {
				$links[] = self::getLink($raw, $name, $definition);
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

	public static function getCategories($yaml, $language) {
		$result = array();

		foreach ($yaml["general"]["categoryNames"] as $id => $name) {
			$cat = new Category;
			$cat->id = $id;
			if (self::hasDeepProperty($yaml, 'translation', $language, 'general', 'categoryNames', $id))
				$cat->name = $yaml["translation"][$language]["general"]["categoryNames"][$id];
			else
				$cat->name = $name;
			$result[] = $cat;
		}

		return $result;
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

	private static function getLink($raw, $name, $definition) {
		$link = new Link();

		$link->name = $name;

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
