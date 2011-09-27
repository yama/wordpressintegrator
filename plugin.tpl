//<?php
/**
 * WordPress Router
 * 
 * WordPress Integrator
 *
 * @category 	plugin
 * @version 	1.2.3
 * @license 	BSD (http://www.opensource.org/licenses/bsd-license.php)
 * @internal    @properties &wp_top_id=Blog top ID;text; &alias=WORDPRESS_ALIAS;text;blog &use_event=Use event;list;OnWebPageInit,OnPageNotFound;OnWebPageInit
 * @internal	@events OnWebPageInit, OnPageNotFound 
 * @internal	@modx_category Content
 *
 ***************************************
 * Copyright 2006 uglydog, http://nanabit.net/
 * 
 * History
 *  1.2.2 20100426  Added plugin options
 *  1.2.1 20100224  WordPress2.9.1
 *  1.2.0 20070421  alias path support with WordPressRouter
 *  1.1.0 20070418  alias path support
 *  1.0.1 20070213  WordPress 2.1 support
 *  1.0.0 20061225  latest entry support
 *  0.0.2 20061128  placeholders support
 *  0.0.1 20061126  minor fix, modx2wp.php added
 *  0.0.0 20061125  new
 * 
 * Credit:
 *  naka (original idea of Hook WordPress)
 **************************************/
/*
 Installation:
 1. replace all =& to = in wp-settings.php
 2. with a higher version than WP 2.1.3, grep all "global $..." in WP source codes,
    and add them to WordPress Integrator (if not exists).
 
 Without Alias Path:
    use WordPressRouter or HookWordPress.
 
 With Alias Path:
    use HookWordPress. (place it in the 404 document.)
*/
/*
  Configuration:
  
    retrives the friendly URL and pass it to WordPress Snippet
    (id=[PAGE_POST], [PAGE_CATEGORY], ..) in proper way.
*/

// the ID and alias of document where WordPressIntegrator snippet exists.
define ('PAGE_WP_TOP', $wp_top_id);
define ('WORDPRESS_ALIAS', $alias);

$e = &$modx->event; 
switch ($e->name)
{
	case "OnWebPageInit":
	if ($use_event!=='OnWebPageInit') return;
		if (strpos($_REQUEST['q'], WORDPRESS_ALIAS)===0)
		{
			$this->documentMethod = 'id';
			$this->documentIdentifier = PAGE_WP_TOP;
			$_REQUEST['q'] = $_GET['q'] = str_replace(WORDPRESS_ALIAS.'/', '', $_REQUEST['q']);
		}
		return;
	
	case "OnPageNotFound":
	if ($use_event!=='OnPageNotFound') return;
	if(preg_match("@^".WORDPRESS_ALIAS."/@", $_REQUEST['q']))
	{
		$modx->sendforward(PAGE_WP_TOP);
	}
		return;
	
	default:
		return; // stop here
}
