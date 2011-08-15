#############################################################################
# This script replaces your facebook image urls with imgur
# Usfull if you dont want to expose userID wich is hidden within the fb URL
# USAGE: Just type the URL and it wil get replaced with imgur url
# perl module Image:Imgur is required (`cpan Image::Imgurl`)
## Settings:
# /set fbimgur_apikey <key>
# 	- Need to be set, get one from http://imgur.com/register/api_anon
# /set fbimgur_continue ON|OFF
#	- if ON, the url wil get sent even on error (default: ON)
##############################################################################

use strict;
use Irssi qw(print settings_add_str settings_get_str settings_get_bool settings_add_bool);
use warnings;
use Image::Imgur;
use vars qw($VERSION %IRSSI);

%IRSSI = (
    authors     => 'NChief',
    contact     => 'NChief@freenode',
    name        => 'Facebook img to imgur',
    description => 'Turns your facebook image urls to imgur urls when posted to channel. perl module Image::Imgur required',
    license     => 'Public domain',
);

$VERSION = "1.0";

settings_add_str('fbimgur', 'fbimgur_apikey', '');
settings_add_bool('fbimgur', 'fbimgur_continue', 1); # Send the url even if error?

sub check_fb {
	my ($text, $server, $witem) = @_;
	if (($text =~ /(http.*(photos.*akamaihd\.net|photos.*fbcdn\.net).*\.jpg)/) && (settings_get_str('fbimgur_apikey'))) {
		my $url = $1;
		my $ourl = $url;
		$url =~ s/https/http/;
		
		my $imgurkey = settings_get_str('fbimgur_apikey');
		my $imgur = new Image::Imgur(key => $imgurkey);
		my $imgur_url = $imgur->upload($url);

		unless ($imgur_url =~ /^(\d+\.?\d*|\.\d+|\-1|\-3)$/) { # unless some error
			$text =~ s/\Q$ourl\E/$imgur_url/;
			Irssi::signal_continue($text, $server, $witem);
		} else {
			print CRAP "\002fbimgur\002 returned error code: ".$imgur_url;
			Irssi::signal_stop() unless settings_get_bool('fbimgur_continue');
		}
	}
}

unless (settings_get_str('fbimgur_apikey')) {
	print CRAP "You need to set API key, you can get it at http://imgur.com/register/api_anon";
	print CRAP "/set fbimgur_apikey <apikey>";
}

Irssi::signal_add('send text', 'check_fb');