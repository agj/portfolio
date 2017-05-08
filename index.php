<?php

error_reporting(E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_RECOVERABLE_ERROR | E_DEPRECATED | E_WARNING);

require_once 'php/lib/autoload.php';
require_once 'php/lambelo.php';
require_once 'php/parser.php';
require_once 'php/utils.php';


$markdown = new League\CommonMark\CommonMarkConverter();

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

if ($settings['shuffle']) {
	shuffle($works);
}

// Header. Breaks stuff with the mediabox crap. :/
//header('Content-Type: application/xhtml+xml; charset=utf-8');


?><!DOCTYPE html>

<html>
<head>
	<meta charset="utf-8" />

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
<?php if ($settings["languages"]): ?>
	<div id="languages">
		<?php if ($language && $settings["languages"][$language]): ?>
			<a href="./">&rarr; <?= $settings["defaultLanguageName"] ?></a>
		<?php endif ?>
		<?php foreach ($settings["languages"] as $lang => $langName): ?>
			<?php if ($lang != $language): ?>
				<a href="?lang=<?= $lang ?>">&rarr; <?= $langName ?></a>
			<?php endif ?>
		<?php endforeach ?>
	</div>
<?php endif ?>

<div id="top" class="text">
	<?= $markdown->convertToHTML($general['presentation']) ?>
</div>

<!-- Filter -->
<hr />
<div id="filter" class="text">
	<?= $general['filterLabel'] ?>
	<?php foreach (Parser::getCategories($general, $language) as $cat): ?>
		<label>
			<input id="check-<?= $cat->id ?>" type="checkbox" checked />
			<?= $cat->name ?>
		</label>
	<?php endforeach ?>
</div>
<hr />


<!--*************************************-->


<?php foreach ($works as $w): ?>
	<!-- WORK: <?= strtoupper($w->name) ?> -->
	<div id="work-<?= $w->id ?>" class="work <?php foreach ($w->category as $cat) echo 'cat-' . $cat . ' '; ?>">
		<div class="name">
			<h1><?= $w->name ?></h1>
			<p><?= $w->type ?> <span class="year"><?= $w->year ?></span></p>
			<img alt="" src="data/works/<?= $w->id ?>/<?= $w->image ?>" />
			<?php if ($w->links): ?>
				<ul>
					<?php foreach ($w->links as $l): ?>
						<li><a href="<?= $l->url ?>" <?= Parser::getLightboxString($l, $w->id) ?>><?= $l->name ?></a></li>
					<?php endforeach ?>
				</ul>
			<?php endif ?>
		</div>
		<div class="description">
			<?= $w->description ?>
			<p><a class="ext-link" href="<?= $w->readMore ?>"><?= $w->readMoreLabel ?></a></p>
		</div>
	</div>

	<hr />

<?php endforeach ?>


<!--*************************************-->


<div id="bottom" class="text">
	<?= $markdown->convertToHTML($general['closing']) ?>
</div>


</body>

</html>