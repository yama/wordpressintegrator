<?php
/***************************************
 * WordPress Integrator
 * 
 * WordPress Integrator
 *
 * @category 	snippet
 * @version 	1.2.3
 * @license 	BSD (http://www.opensource.org/licenses/bsd-license.php)
 * @internal    @properties &wp_path=WP_PATH;text;wp
 * @internal	@modx_category Content
 * 
 * Copyright 2006 uglydog, http://nanabit.net/
 * 
 * History
 *  1.2.3 20100623  
 *  1.2.2 20100426  
 *  1.2.1 20100224  add some global var
 *  1.2.0 20070421  alias path support with WordPressRouter
 *  1.1.0 20070418  alias path support
 *  1.0.1 20070213  WordPress 2.1 support
 *  1.0.0 20061225  latest entry support
 *  0.0.2 20061128  placeholders support
 *  0.0.1 20061126  minor fix, modx2wp.php added
 *  0.0.0 20061125  new
 **************************************/

// Snippet options
$block = isset($block) ? $block : 'body'; //body, sidebar, latest

// Snippet settings
define ('WPMODX_WP_PATH', MODX_BASE_PATH . $wp_path);
define ('WPMODX_TITLE', 'the title to show if the given one is blank');

if (!function_exists("wpmodx_load_wp_template"))
{
  function wpmodx_load_wp_template($path)
  {
    $file_content = file_get_contents($path);
    $file_content = str_replace("get_header()", "null", $file_content);
    $file_content = str_replace("get_footer()", "null", $file_content);
    $file_content = str_replace("get_sidebar()", "null", $file_content);
    eval("?>".$file_content."<?");
  }
}


// load WordPress
global $wp;
global $wpdb;
global $wp_rewrite;
global $wp_query, $wp_the_query, $wp_locale;
global $allowedtags;
global $wp_did_header;

global $timestart;
global $post_default_category;
global $cache_categories;
global $post;
global $withcomments;
global $id;
global $comment;
global $user_login;
global $user_identity;
global $comment_count_cache;
global $wpcommentspopupfile, $wptrackbackpopupfile, $wppingbackpopupfile, $wpcommentsjavascript;
global $cache_lastcommentmodified;
global $pagenow;
global $postc, $commentdata;
global $wp_version;
global $wp_smiliessearch, $wp_smiliesreplace;
global $weekday, $month_abbrev, $weekday_abbrev;
global $post_meta_cache;
global $allowedtags, $allowedposttags;
global $m, $year, $monthnum, $day, $category_name, $month;
global $timedifference, $weekday_initial, $previousweekday;
global $posts;
global $preview, $user_ID;
global $current_user, $wp_roles;
global $table_prefix;
global $posts_per_page;
global $paged,$nextpage,$prevpage;
global $wp_registered_widgets, $wp_registered_widget_controls, $wp_registered_widget_updates, $_wp_deprecated_widgets_callbacks;
global $wp_embed, $wp_widget_factory, $wp_taxonomies;

define ('WP_USE_THEMES', false);
if (!isset($wp_did_header)) {
  $wp_did_header = true;
  require_once( WPMODX_WP_PATH . '/wp-config.php');
  wp();
}

// sidebar
if ($block=='sidebar') {
  get_sidebar();
  //overwrite (if not, sidebar query will return 404)
  header("HTTP/1.1 200 OK", true);
  header("Status: 200 OK",  true);
  return;
}

// latest
if ($block=='latest') {
  $wp_query->set('posts_per_page', 1);
  $wp_query->set('what_to_show', 'posts');
  $posts = $wp_query->get_posts();
  $paged = 0.1; // ugly hack. ref: link-template.php
} else {
  $posts = $wp_query->get_posts();
}

// Placeholders
$modx->setPlaceholder("wp_home", get_bloginfo("home"));
$modx->setPlaceholder("wp_wpurl", get_bloginfo("wpurl")); // WordPress admin URL
$modx->setPlaceholder("wp_description", get_bloginfo("description"));
$modx->setPlaceholder("wp_rdf_url", get_bloginfo("rdf_url"));
$modx->setPlaceholder("wp_rss_url", get_bloginfo("rss_url"));
$modx->setPlaceholder("wp_rss2_url", get_bloginfo("rss2_url"));
$modx->setPlaceholder("wp_atom_url", get_bloginfo("atom_url"));
$modx->setPlaceholder("wp_comments_rss2_url", get_bloginfo("comments_rss2_url"));
$modx->setPlaceholder("wp_pingback_url", get_bloginfo("pingback_url"));
$modx->setPlaceholder("wp_stylesheet_url", get_bloginfo("stylesheet_url"));
$modx->setPlaceholder("wp_stylesheet_directory", get_bloginfo("stylesheet_directory"));
$modx->setPlaceholder("wp_template_directory", get_bloginfo("template_directory"));
$modx->setPlaceholder("wp_template_url", get_bloginfo("template_url"));
$modx->setPlaceholder("wp_admin_email", get_bloginfo("admin_email"));
$modx->setPlaceholder("wp_charset", get_bloginfo("charset"));
$modx->setPlaceholder("wp_html_type", get_bloginfo("html_type"));
$modx->setPlaceholder("wp_version", get_bloginfo("version"));
$modx->setPlaceholder("wp_name", get_bloginfo("name"));

$title = wp_title('', false);
$modx->setPlaceholder("wp_pagetitle", empty($title) ? WPMODX_TITLE : $title);


// load template (/wp-includes/template-loader.php)
if ( is_feed() ) {
  $doing_rss = 1;
  include( WPMODX_WP_PATH . '/wp-feed.php');
  exit;
} else if ( is_trackback() ) {
  include( WPMODX_WP_PATH . '/wp-trackback.php');
  exit;
} else if ( is_404() && $template = get_404_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_search() && $template = get_search_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_home() && $template = get_home_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_attachment() && $template = get_attachment_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_single() && $template = get_single_template() ) {
  if ( is_attachment() )
    add_filter('the_content', 'prepend_attachment');
  wpmodx_load_wp_template($template);
} else if ( is_page() && $template = get_page_template() ) {
  if ( is_attachment() )
    add_filter('the_content', 'prepend_attachment');
  wpmodx_load_wp_template($template);
} else if ( is_category() && $template = get_category_template()) {
  wpmodx_load_wp_template($template);
} else if ( is_author() && $template = get_author_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_date() && $template = get_date_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_archive() && $template = get_archive_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_comments_popup() && $template = get_comments_popup_template() ) {
  wpmodx_load_wp_template($template);
} else if ( is_paged() && $template = get_paged_template() ) {
  wpmodx_load_wp_template($template);
} else if ( file_exists(TEMPLATEPATH . "/index.php") ) {
  if ( is_attachment() )
    add_filter('the_content', 'prepend_attachment');
  wpmodx_load_wp_template(TEMPLATEPATH . "/index.php");
}
?>