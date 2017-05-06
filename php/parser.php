<?php

class Parser {

	public static function getWorks($yaml, $language) {
		if (self::hasDeepProperty($yaml, 'translation', $language))
			$generalTranslation = $yaml["translation"][$language];
		
		$works = array();
		foreach ($yaml["works"] as $i => $rawW) {
			if (isset($rawW["hide"]) && $rawW["hide"] === true)
				continue;
			
			$w = new Work();
			$w->id = $i;
			$w->name = self::getWorkValue($language, $rawW, 'name');
			$w->type = self::getWorkValueExtended($yaml, $language, $rawW, 'type');
			$w->year = $rawW["year"];
			$w->image = self::getWorkValue($language, $rawW, 'image');
			$w->description = self::getWorkValue($language, $rawW, 'description');
			$w->category = $rawW["category"];
			$w->readMore = self::getWorkValue($language, $rawW, 'readMore');
			
			if ($generalTranslation) {
				if (self::hasDeepProperty($rawW, 'translation', $language, 'readMore'))
					$w->readMoreLabel = $generalTranslation["general"]["readMore"];
				else
					$w->readMoreLabel = $generalTranslation["general"]["readMoreNonTranslated"];
			} else {
				$w->readMoreLabel = $yaml["general"]["readMore"];
			}
			
			if (isset($rawW["links"])) {
				$links = array();
				foreach ($rawW["links"] as $prop => $value) {
					$links[] = self::getLink($yaml, $language, $rawW, $prop, $value);
				}
				$w->links = $links;
			}
			
			$works[] = $w;
		}
		
		shuffle($works);
		
		return $works;
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
			return $rawW["translation"][$language][$prop];
		else if (self::hasDeepProperty($yaml, 'translation', $language, 'works', $prop, $rawW[$prop]))
			return $yaml["translation"][$language]["works"][$prop][$rawW[$prop]];
		return $rawW[$prop];
	}
	
	private static function getLink($yaml, $language, $rawW, $prop, $value) {
		$link = new Link();
		
		if (self::hasDeepProperty($rawW, 'translation', $language, 'links', $prop))
			$link->name = $rawW["translation"][$language]["links"][$prop];
		else if (self::hasDeepProperty($yaml, 'general', 'translation', $language, 'works', 'links', $prop))
			$link->name = $yaml["general"]["translation"][$language]["works"]["links"][$prop];
		else
			$link->name = $prop;
		
		if (is_string($value)) {
			$link->url = $value;
			$link->popup = true;
		} else {
			$link->url = $value["url"];
			$link->popup = (!isset($value["popup"]) || $value["popup"] === true);
			if ($link->popup) {
				if (isset($value["width"]))	$link->width = $value["width"];
				if (isset($value["height"]))	$link->height = $value["height"];
				if (isset($value["color"]))	$link->color = $value["color"];
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

?>