<?php

error_reporting(E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_RECOVERABLE_ERROR | E_DEPRECATED | E_WARNING);
// error_reporting(E_ALL);

require_once 'php/lambelo.php';
require_once 'php/spyc.php';
require_once 'php/parser.php';

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

$language = $_REQUEST['lang'];

$settings = Spyc::YAMLLoad('data/settings.yaml');
$general = Spyc::YAMLLoad('data/general/default.yaml');
if (file_exists("data/general/$language.yaml"))
	$general = $deepMerge($general, Spyc::YAMLLoad("data/general/$language.yaml"));
$replacements = null;
if ("data/general/replacements/$language.yaml")
	$replacements = Spyc::YAMLLoad("data/general/replacements/$language.yaml");

$workslist = L::map(basename, glob('data/works/*', GLOB_ONLYDIR));

$toLang = $replace('/.*\/([^\/]+).yaml/', '$1');
$yamlWorks = L::foldOn($workslist, array(), function ($acc, $name) use ($toLang) {
	$langs = L::map($toLang, glob("data/works/$name/*.yaml"));
	$acc[$name] = L::foldOn($langs, array(), function ($acc, $lang) use ($name) {
		$acc[$lang] = Spyc::YAMLLoad("data/works/$name/$lang.yaml");
		return $acc;
	});
	return $acc;
});

$works = L::filterOn(
	L::mapIdxOn($yamlWorks, function ($w, $id) use ($language, $general, $replacements) {
		return Parser::parseWork($id, $w, $language, $general, $replacements);
	}),
	function ($w) { return isset($w); }
);
$w;

if ($settings["randomize"]) {
	shuffle($works);
}

// Header. Breaks stuff with the mediabox crap. :/
//header('Content-Type: application/xhtml+xml; charset=utf-8');


?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />

	<title><?= $general['title']; ?></title>
	<link rel="icon" type="image/gif" href="/icon.gif" />

	<link rel="stylesheet" type="text/css" href="css/style.css" />

	<link rel="stylesheet" href="css/mediabox/mediaboxAdv-Minimal.css" type="text/css" media="screen" />
	<script src="js/mootools.js" type="text/javascript"></script>
	<script src="js/mediaboxAdv.js" type="text/javascript"></script>
	<script src="js/filter.js" type="text/javascript"></script>
</head>

<body>


<!-- Presentation -->
<?php
	if ($settings["languages"]) {
		echo '<div id="languages">';
		if ($language && $settings["languages"][$language])
			echo '<a href="./">&rarr; ' . $settings["defaultLanguageName"] . '</a>';
		foreach ($settings["languages"] as $lang => $langName) {
			if ($lang != $language)
				echo '<a href="?lang=' . $lang . '">&rarr; ' . $langName . '</a>';
		}
		echo '</div>';
	}
?>

<div id="top" class="text">
<p><?= $general['presentation'] ?></p>
</div>

<!-- Filter -->
<hr />
<div id="filter" class="text">
<?php

	echo ' ' . $general['filterLabel'] . $br;

	$categories = Parser::getCategories($general, $language);

	foreach ($categories as $cat) {
		echo '	<label>' . $br;
		echo '		<input id="check-' . $cat->id . '" type="checkbox" checked="checked" />' . $br;
		echo '		' . $cat->name . $br;
		echo '	</label>' . $br;
	}

?>
</div>
<hr />


<!--*************************************-->


<?php foreach ($works as $w): ?>
	<!-- WORK: <?= strtoupper($w->name) ?> -->
	<div id="work-<?= $w->id ?>" class="work cat-<?= $w->category ?>">
		<div class="name">
			<h1><?= $w->name ?></h1>
			<p><?= $w->type ?> <span class="year"><?= $w->year ?></span></p>
			<img alt="" src="data/works/<?= $w->id ?>/01.jpg" />
			<?php if ($w->links): ?>
				<ul>
					<?php foreach ($w->links as $l): ?>
						<li><a href="<?= $l->url ?>"><?= $l->name ?></a></li>
					<?php endforeach ?>
				</ul>
			<?php endif ?>
		</div>
		<div class="description">
			<p><?= $w->description ?></p>
			<p><a class="ext-link" href="<?= $w->readMore ?>"><?= $w->readMoreLabel ?></a></p>
		</div>
	</div>

	<hr />

<?php endforeach ?>


<!--*************************************-->


<div id="bottom" class="text">
	<p><?= $general['closing']; ?></p>
</div>


</body>

</html>