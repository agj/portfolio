<?php

include 'classes.php';
include 'parser.php';

$br = "\n";

$language = $_REQUEST['lang'];

$json = json_decode(file_get_contents('data.json'), false);

$works = Parser::getWorks($json);
$w;



?><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
	<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />

	<title>Alejandro Grilli J.'s portfolio</title>
	<meta name="description" content="Alejandro Grilli J.'s portfolio" />
	<link rel="icon" type="image/gif" href="/icon.gif" />
	
	<link rel="stylesheet" type="text/css" href="css/style.css" />
	<script src="js/filter.js" type="text/javascript"></script>
	
	<link rel="stylesheet" href="css/mediaboxAdvAgj.css" type="text/css" media="screen" />
	<script src="js/mootools.js" type="text/javascript"></script>
	<script src="js/mediaboxAdv.js" type="text/javascript"></script>
</head>

<body>


<!-- Presentation -->
<?php
	if ($json->general->languages) {
		echo '<div id="languages">';
		if ($language && $json->general->languages->{$language})
			echo '<a href="./">&rarr; ' . $json->general->defaultLanguageName . '</a>';
		foreach ($json->general->languages as $lang => $langName) {
			if ($lang != $language)
				echo '<a href="?lang=' . $lang . '">&rarr; ' . $langName . '</a>';
		}
		echo '</div>';
	}
?>

<div id="top" class="text">
<p><?php echo Parser::getGeneralValue($json, 'presentation'); ?></p>
</div>

<!-- Filter -->
<hr />
<div id="filter" class="text">
<?php
	
	echo ' ' . Parser::getGeneralValue($json, 'filterLabel') . $br;

	$categories = Parser::getCategories($json);
	
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
	<p><?php echo Parser::getGeneralValue($json, 'closing'); ?></p>
</div>


</body>

</html>