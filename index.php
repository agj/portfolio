<?php

error_reporting(E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_RECOVERABLE_ERROR | E_DEPRECATED | E_WARNING);

require_once 'php/lib/autoload.php';
require_once 'php/lambelo.php';
require_once 'php/parser.php';
require_once 'php/utils.php';


$markdown = new League\CommonMark\CommonMarkConverter();

$settings = Spyc::YAMLLoad('data/settings.yaml');
$language = $getLanguage(array_keys($settings['languages']));
$general = Spyc::YAMLLoad('data/general/default.yaml');
if (file_exists("data/general/$language.yaml"))
	$general = $deepMerge($general, Spyc::YAMLLoad("data/general/$language.yaml"));
$replacements = null;
if ("data/general/replacements/$language.yaml")
	$replacements = Spyc::YAMLLoad("data/general/replacements/$language.yaml");
$categories = Parser::getCategories($general, $language);

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


?><!DOCTYPE html>

<html>
<head>
	<meta charset="utf-8" />

	<title><?= $general['title']; ?></title>
	<link rel="icon" type="image/gif" href="/icon.gif" />

	<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=yes" />

	<link href="css/reset.css" rel="stylesheet" type="text/css" />
	<link href="css/base.css" rel="stylesheet" type="text/css" />
	<link href="css/responsive.css" rel="stylesheet" type="text/css" />
	<link href="css/popups.css" rel="stylesheet" type="text/css" />

	<style>
		<?php foreach ($categories as $cat): ?>
		#works.visible-cat-<?= $cat->id ?> .work.cat-<?= $cat->id ?> {
			/* max-height: 50em; */
			display: flex;
			/* margin-top: 15px; */
			/* margin-bottom: 15px; */
		}
		<?php endforeach ?>
	</style>
</head>

<body class="lang-<?= (isset($language) ? $language : 'default') ?>">


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
	<span>
		<?= $general['filterLabel'] ?>
	</span>
	<?php foreach ($categories as $cat): ?>
		<span class="check check-<?= $cat->id ?>">
			<input id="check-<?= $cat->id ?>" type="checkbox" checked /><label for="check-<?= $cat->id ?>"><?= $cat->name ?></label>
		</span>
	<?php endforeach ?>
</div>

<hr />


<!--*************************************-->

<section id="works" class="<?php foreach ($categories as $cat) { echo ' visible-cat-' . $cat->id; } ?>">
	<?php foreach ($works as $w): ?>
		<!-- WORK: <?= strtoupper($w->name) ?> -->
		<div id="work-<?= $w->id ?>" class="work <?php foreach ($w->category as $cat) echo 'cat-' . $cat . ' '; ?>">
			<div class="head">
				<h1 class="title"><?= $w->name ?></h1>
				<p class="type"><?= $w->type ?> <span class="year"><?= $w->year ?></span></p>
				<div class="image"><img alt="" src="data/works/<?= $w->id ?>/<?= $w->image ?>" /></div>
				<?php if ($w->links): ?>
					<ul class="links popup-group">
						<?php foreach ($w->links as $l): ?>
							<li class="link">
								<a
									href="<?= $l->url ?>"
									<?php if ($l->popup): ?>
										class="open-popup"
										data-popup="<?php
											if (isset($l->width))  echo "$l->width $l->height ";
											if (isset($l->color))  echo $l->color;
										?>"
									<?php endif ?>
								>
									<?= $l->name ?>
								</a>
							</li>
						<?php endforeach ?>
					</ul>
				<?php endif ?>
			</div>
			<div class="description">
				<?= $w->description ?>
				<p><a class="ext-link" href="<?= $w->readMore ?>"><?= $w->readMoreLabel ?></a></p>
			</div>
		</div>
	<?php endforeach ?>
</section>


<!--*************************************-->

<hr />

<div id="bottom" class="text">
	<?= $markdown->convertToHTML($general['closing']) ?>
</div>


</body>

<script src="js/filter.js"></script>
<script src="js/popups.js"></script>

</html>