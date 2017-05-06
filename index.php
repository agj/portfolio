<?php

//error_reporting(E_ERROR | E_PARSE | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR | E_RECOVERABLE_ERROR | E_DEPRECATED | E_WARNING);
//error_reporting(E_ALL);

include 'php/spyc.php';
include 'php/classes.php';
include 'php/parser.php';

$br = "\n";

$language = $_REQUEST['lang'];

$yaml = Spyc::YAMLLoad('data.yaml');

$works = Parser::getWorks($yaml, $language);
$w;

if ($yaml["settings"]["randomize"]) {
	shuffle($works);
}

// Header. Breaks stuff with the mediabox crap. :/
//header('Content-Type: application/xhtml+xml; charset=utf-8');


?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />

	<title><?php echo Parser::getGeneralValue($yaml, $language, 'title'); ?></title>
	<meta name="description" content="Alejandro Grilli J.'s portfolio" />
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
	if ($yaml["settings"]["languages"]) {
		echo '<div id="languages">';
		if ($language && $yaml["settings"]["languages"][$language])
			echo '<a href="./">&rarr; ' . $yaml["settings"]["defaultLanguageName"] . '</a>';
		foreach ($yaml["settings"]["languages"] as $lang => $langName) {
			if ($lang != $language)
				echo '<a href="?lang=' . $lang . '">&rarr; ' . $langName . '</a>';
		}
		echo '</div>';
	}
?>

<div id="top" class="text">
<p><?php echo Parser::getGeneralValue($yaml, $language, 'presentation'); ?></p>
</div>

<!-- Filter -->
<hr />
<div id="filter" class="text">
<?php
	
	echo ' ' . Parser::getGeneralValue($yaml, $language, 'filterLabel') . $br;

	$categories = Parser::getCategories($yaml, $language);
	
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


<?php

foreach ($works as $w) {
	echo '<!-- WORK: ' . strtoupper($w->name) . ' -->' . $br;
	echo '<div id="work-' . $w->id . '" class="work cat-' . $w->category . '">' . $br;
	echo '	<div class="name">' . $br;
	echo '		<h1>' . $w->name . '</h1>' . $br;
	echo '		<p>' . $w->type . ' <span class="year">' . $w->year . '</span></p>' . $br;
	echo '		<img alt="" src="img/' . $w->image . '" />' . $br;
	if ($w->links) {
		echo '		<ul>' . $br;
		foreach ($w->links as $l) {
			echo '			<li><a href="' . $l->url . '"' . Parser::getLightboxString($l, $w->id) . '>' . $l->name . '</a></li>' . $br;
		}
		echo '		</ul>' . $br;
	}
	echo '	</div>' . $br;
	echo '	<div class="description">' . $br;
	echo '		<p>' . $w->description . '</p>' . $br;
	if ($w->readMore)
		echo '		<p><a class="ext-link" href="' . $w->readMore . '">' . $w->readMoreLabel . '</a></p>' . $br;
	echo '	</div>' . $br;
	echo '</div>' . $br;
	echo $br . $br;
	echo '<hr />';
	echo $br . $br;
}

?>
<!--*************************************-->


<div id="bottom" class="text">
	<p><?php echo Parser::getGeneralValue($yaml, $language, 'closing'); ?></p>
</div>


</body>

</html>