<?php

class Parser {

	public static function getWorks($json) {
		global $language;
		
		if (self::hasDeepProperty($json, 'general', 'translation', $language))
			$generalTranslation = $json->general->translation->{$language};
		
		$works = array();
		foreach ($json->works as $i => $rawW) {
			if ($rawW->hide === "true")
				continue;
			
			$w = new Work();
			$w->id = $i;
			$w->name = self::getWorkValue($rawW, 'name');
			$w->type = self::getWorkValueExtended($json, $rawW, 'type');
			$w->year = $rawW->year;
			$w->image = self::getWorkValue($rawW, 'image');
			$w->description = self::getWorkValue($rawW, 'description');
			$w->category = $rawW->category;
			$w->readMore = self::getWorkValue($rawW, 'readMore');
			
			if ($generalTranslation) {
				if (self::hasDeepProperty($rawW, 'translation', $language, 'readMore'))
					$w->readMoreLabel = $generalTranslation->general->readMore;
				else
					$w->readMoreLabel = $generalTranslation->general->readMoreNonTranslated;
			} else {
				$w->readMoreLabel = $json->general->readMore;
			}
			
			$srcLinks = self::getWorkValue($rawW, 'links');
			if ($rawW->links) {
				$links = array();
				foreach ($rawW->links as $prop => $value) {
					$links[] = self::getLink($json, $rawW, $prop, $value);
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
		
		$result = ' rel="lightbox[work' . $group;
		if ($link->width)
			$result .= ' ' . $link->width;
		if ($link->height)
			$result .= ' ' . $link->height;
		if ($link->color)
			$result .= ' ' . $link->color;
		$result .= ']"';
		
		return $result;
	}
	
	public static function getCategories($json) {
		global $language;
		$result = array();
		
		foreach ($json->general->categoryNames as $id => $name) {
			$cat = new Category;
			$cat->id = $id;
			if (self::hasDeepProperty($json, 'general', 'translation', $language, 'general', 'categoryNames', $id))
				$cat->name = $json->general->translation->{$language}->general->categoryNames->{$id};
			else
				$cat->name = $name;
			$result[] = $cat;
		}
		
		return $result;
	}
	
	public static function getGeneralValue($json, $prop) {
		global $language;
		
		if (self::hasDeepProperty($json, 'general', 'translation', $language, 'general', $prop))
			return $json->general->translation->{$language}->general->{$prop};
		return $json->general->{$prop};
	}
	
	/////
	
	private static function getWorkValue($rawW, $prop) {
		global $language;
		if (self::hasDeepProperty($rawW, 'translation', $language, $prop))
			return $rawW->translation->{$language}->{$prop};
		return $rawW->{$prop};
	}
	
	private static function getWorkValueExtended($json, $rawW, $prop) {
		global $language;
		if (self::hasDeepProperty($rawW, 'translation', $language, $prop))
			return $rawW->translation->{$language}->{$prop};
		else if (self::hasDeepProperty($json, 'general', 'translation', $language, 'works', $prop, $rawW->{$prop}))
			return $json->general->translation->{$language}->works->{$prop}->{$rawW->{$prop}};
		return $rawW->{$prop};
	}
	
	private static function getLink($json, $rawW, $prop, $value) {
		global $language;
		$link = new Link();
		
		if (self::hasDeepProperty($rawW, 'translation', $language, 'links', $prop))
			$link->name = $rawW->translation->{$language}->links->{$prop};
		else if (self::hasDeepProperty($json, 'general', 'translation', $language, 'works', 'links', $prop))
			$link->name = $json->general->translation->{$language}->works->links->{$prop};
		else
			$link->name = $prop;
		
		if (is_string($value)) {
			$link->url = $value;
			$link->popup = true;
		} else {
			$link->url = $value->url;
			$link->popup = (!$value->popup || $value->popup === "true");
			if ($link->popup) {
				if ($value->width)	$link->width = $value->width;
				if ($value->height)	$link->height = $value->height;
				if ($value->color)	$link->color = $value->color;
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
			$current = $current->{$arg};
			if (!$current)
				return false;
		}
		return true;
	}
	
}

?>