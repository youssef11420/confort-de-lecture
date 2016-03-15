#!/usr/bin/perl

#########################################################################
# BEGIN COPYRIGHT, LICENSE AND WARRANTY NOTICE
# SOFTWARE NAME: Confort de lecture
# SOFTWARE RELEASE: 2.0.0
# COPYRIGHT NOTICE: Copyright (C) 2000-2007 GIE Confort de lecture (aYaline & HandicapZéro)
# SOFTWARE LICENSE: GNU General Public License v3
# NOTICE:
# This file is part of Confort de lecture.
#
# Confort de lecture is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# Confort de lecture is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Confort de lecture. If not, see <http://www.gnu.org/licenses/>.
#########################################################################

# File: index.pl
#	Script principal de traitement des pages HTML, et de centralisation des autres traitements

use CGI::Carp qw(fatalsToBrowser);

use CGI qw(:standard);
use CGI::Session;

use Cwd;

if (-e "./JSON") {
	use lib 'JSON';
}
use JSON;

use LWP::UserAgent;
use HTML::TreeBuilder;
%HTML::Tagset::optionalEndTag = map {; $_ => 1}
	qw(dt dd li thead th tbody tr td tfoot colgroup col hr br param img area input base meta link empbed keygen source track wbr);
%HTML::Tagset::emptyElement = map {; $_ => 1} qw();
%HTML::Tagset::isPhraseMarkup = map {; $_ => 1} qw();
%HTML::Tagset::isHeadElement = map {; $_ => 1}
	qw(title base link meta isindex script);
%HTML::Tagset::isBodyElement = map {; $_ => 1} qw(
	h1 h2 h3 h4 h5 h6
	p div pre address blockquote

	iframe

	hr
	ol ul dir menu li
	dl dt dd
	ins del

	fieldset legend

	map area
	applet param object embed
	isindex script noscript
	table
	form

	span abbr acronym q sub sup
	cite code em kbd samp strong var dfn strike
	b i u s tt
	a img br
	bdo
),
keys %HTML::Tagset::isFormElement,
keys %HTML::Tagset::isPhraseMarkup,
keys %HTML::Tagset::isTableElement;
%HTML::Tagset::isHeadOrBodyElement = map {; $_ => 1}
	qw(script noscript isindex style object map area param);

use lib '../modules/utils';
use config_manager;
use constants;
use misc_utils;
use session;

use lib '../modules/html';
use applets;
use forms;
use frames_iframes;
use images_maps;
use javascript;
use links;
use misc_html;
use objects;
use page_head;
use tables;

use lib '../modules/cdl_tags';
use bloc;
use cdl_tag;
use change_replace;
use exclure;
use nav;
use position;

use lib '../modules/pages';
use index_page;

$embeddedMode = "";

processIndexPage;