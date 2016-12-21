#!/usr/bin/env perl
use strict;
use warnings;

use LWP::Simple;
use Digest::MD5;
use File::Copy qw(move);

my $url="http://www.badips.com/get/list/http/0";
my $tmp_file="/tmp/blockips.conf";
my $nginx_conffile="blockips.conf";
my $script_name=$0;

my $response= get($url) or die "Cannot get bad ip list";
my @ip_list=map {s/\s+//g; $_} sort map {s/(\d+)/sprintf "%3s", $1/eg; $_} split('\n',$response);

if(scalar(@ip_list) > 0){
	my $tmp_fh;
	open($tmp_fh,">",$tmp_file) or die "Cannot open temporary file";
	foreach(@ip_list){
		print $tmp_fh "deny ".$_.";\n";
	}
	close $tmp_fh;
	my $nginx_md5=md5sum($nginx_conffile);
	my $tmp_md5=md5sum($tmp_file);
	if($nginx_md5 ne $tmp_md5){
		move $tmp_file, $nginx_conffile;
	}
}

sub md5sum{
	my $file=shift;
	my $digest="";
	if(-e $file){
		open(FH,$file) or die "Can't open file for md5sum\n";
		my $md5=Digest::MD5->new;
		$md5->addfile(*FH);
		$digest=$md5->hexdigest;
		close(FH);
	}

	return $digest;
}
__END__;


References:
	1. https://www.badips.com/documentation#7
	2. https://github.com/DataIX/blockips-nginx

	API:
	GET /add/<category>/<IP>
	GET /get/categories
	GET /get/stats/count
	GET /get/stats/countbycountry
	GET /get/stats/countbycategory
	GET /get/stats/countbyopenport
	GET /get/list/<category>/<score>
	GET /get/info/<IP>
	GET /get/country/<country>
	GET /get/key
	GET /set/key/<key>
