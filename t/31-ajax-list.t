#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';
use lib qw( t/lib );

use Test::More 'no_plan';
use JSON::XS;
use Storable;

# application loads
BEGIN { use_ok "Test::WWW::Mechanize::Catalyst::AJAX" => "TestApp" }
my $mech = Test::WWW::Mechanize::Catalyst::AJAX->new;

my $default_album_page = JSON::XS::decode_json(<<'END_DEF_ALBUM');
{"total":5,"rows":[{"cpac__id":"id\u00001","tracks":["Track 1.1","Track 1.2","Track 1.3"],"sleeve_notes":"","deleted":1,"artist_id":"Mike Smith","id":1,"recorded":"1989-01-02","title":"DJ Mix 1","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 1"},{"cpac__id":"id\u00002","tracks":["Track 2.1","Track 2.2","Track 2.3"],"sleeve_notes":"SleeveNotes: id(1)","deleted":1,"artist_id":"Mike Smith","id":2,"recorded":"1989-02-02","title":"DJ Mix 2","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 2"},{"cpac__id":"id\u00003","tracks":["Track 3.1","Track 3.2","Track 3.3"],"sleeve_notes":"","deleted":1,"artist_id":"Mike Smith","id":3,"recorded":"1989-03-02","title":"DJ Mix 3","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 3"},{"cpac__id":"id\u00004","tracks":["Pop Song One"],"sleeve_notes":"","deleted":0,"artist_id":"David Brown","id":4,"recorded":"2007-05-30","title":"Pop Songs","copyright":["Label B"],"cpac__display_name":"Pop Songs"},{"cpac__id":"id\u00005","tracks":["Hit Tune","Hit Tune 3","Hit Tune II"],"sleeve_notes":"","deleted":0,"artist_id":"Adam Smith","id":5,"recorded":"2002-05-21","title":"Greatest Hits","copyright":["Label B"],"cpac__display_name":"Greatest Hits"}]}
END_DEF_ALBUM

my $sorted_track_page = JSON::XS::decode_json(<<'END_SORT_TRACK');
{"total":13,"rows":[{"cpac__id":"id\u000010","length":"1:01","parent_album":"Pop Songs","sales":2685000,"copyright_id":"Label B","title":"Pop Song One","id":10,"cpac__display_name":"Pop Song One","releasedate":"1995-01-04"},{"cpac__id":"id\u000011","length":"2:02","parent_album":"Greatest Hits","sales":1536000,"copyright_id":"Label B","title":"Hit Tune","id":11,"cpac__display_name":"Hit Tune","releasedate":"1990-11-06"},{"cpac__id":"id\u000012","length":"3:03","parent_album":"Greatest Hits","sales":195300,"copyright_id":"Label B","title":"Hit Tune II","id":12,"cpac__display_name":"Hit Tune II","releasedate":"1990-11-06"},{"cpac__id":"id\u000013","length":"4:04","parent_album":"Greatest Hits","sales":1623000,"copyright_id":"Label B","title":"Hit Tune 3","id":13,"cpac__display_name":"Hit Tune 3","releasedate":"1990-11-06"},{"cpac__id":"id\u00007","length":"3:30","parent_album":"DJ Mix 3","sales":1953540,"copyright_id":"Label A","title":"Track 3.1","id":7,"cpac__display_name":"Track 3.1","releasedate":"1998-06-12"},{"cpac__id":"id\u00008","length":"3:40","parent_album":"DJ Mix 3","sales":2668000,"copyright_id":"Label B","title":"Track 3.2","id":8,"cpac__display_name":"Track 3.2","releasedate":"1998-01-04"},{"cpac__id":"id\u00009","length":"3:50","parent_album":"DJ Mix 3","sales":20000,"copyright_id":"Label A","title":"Track 3.3","id":9,"cpac__display_name":"Track 3.3","releasedate":"1999-11-14"},{"cpac__id":"id\u00004","length":"2:30","parent_album":"DJ Mix 2","sales":153000,"copyright_id":"Label B","title":"Track 2.1","id":4,"cpac__display_name":"Track 2.1","releasedate":"1990-01-04"},{"cpac__id":"id\u00005","length":"2:40","parent_album":"DJ Mix 2","sales":1020480,"copyright_id":"Label A","title":"Track 2.2","id":5,"cpac__display_name":"Track 2.2","releasedate":"1991-11-11"},{"cpac__id":"id\u00006","length":"2:50","parent_album":"DJ Mix 2","sales":9625543,"copyright_id":"Label B","title":"Track 2.3","id":6,"cpac__display_name":"Track 2.3","releasedate":"1980-07-21"}]}
END_SORT_TRACK

my $default_track_page = JSON::XS::decode_json(<<'END_DEF_TRACK');
{"total":13,"rows":[{"cpac__id":"id\u00001","length":"1:30","parent_album":"DJ Mix 1","sales":5460000,"copyright_id":"Label A","title":"Track 1.1","id":1,"cpac__display_name":"Track 1.1","releasedate":"1994-04-05"},{"cpac__id":"id\u00002","length":"1:40","parent_album":"DJ Mix 1","sales":1775000,"copyright_id":"Label B","title":"Track 1.2","id":2,"cpac__display_name":"Track 1.2","releasedate":"1995-01-15"},{"cpac__id":"id\u00003","length":"1:50","parent_album":"DJ Mix 1","sales":2100000,"copyright_id":"Label A","title":"Track 1.3","id":3,"cpac__display_name":"Track 1.3","releasedate":"1989-08-18"},{"cpac__id":"id\u00004","length":"2:30","parent_album":"DJ Mix 2","sales":153000,"copyright_id":"Label B","title":"Track 2.1","id":4,"cpac__display_name":"Track 2.1","releasedate":"1990-01-04"},{"cpac__id":"id\u00005","length":"2:40","parent_album":"DJ Mix 2","sales":1020480,"copyright_id":"Label A","title":"Track 2.2","id":5,"cpac__display_name":"Track 2.2","releasedate":"1991-11-11"},{"cpac__id":"id\u00006","length":"2:50","parent_album":"DJ Mix 2","sales":9625543,"copyright_id":"Label B","title":"Track 2.3","id":6,"cpac__display_name":"Track 2.3","releasedate":"1980-07-21"},{"cpac__id":"id\u00007","length":"3:30","parent_album":"DJ Mix 3","sales":1953540,"copyright_id":"Label A","title":"Track 3.1","id":7,"cpac__display_name":"Track 3.1","releasedate":"1998-06-12"},{"cpac__id":"id\u00008","length":"3:40","parent_album":"DJ Mix 3","sales":2668000,"copyright_id":"Label B","title":"Track 3.2","id":8,"cpac__display_name":"Track 3.2","releasedate":"1998-01-04"},{"cpac__id":"id\u00009","length":"3:50","parent_album":"DJ Mix 3","sales":20000,"copyright_id":"Label A","title":"Track 3.3","id":9,"cpac__display_name":"Track 3.3","releasedate":"1999-11-14"},{"cpac__id":"id\u000010","length":"1:01","parent_album":"Pop Songs","sales":2685000,"copyright_id":"Label B","title":"Pop Song One","id":10,"cpac__display_name":"Pop Song One","releasedate":"1995-01-04"}]}
END_DEF_TRACK

my $filtered_album_page = JSON::XS::decode_json(<<'END_FILTER_ALBUM');
{"total":4,"rows":[{"cpac__id":"id\u00001","tracks":["Track 1.1","Track 1.2","Track 1.3"],"sleeve_notes":"","deleted":1,"artist_id":"Mike Smith","id":1,"recorded":"1989-01-02","title":"DJ Mix 1","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 1"},{"cpac__id":"id\u00002","tracks":["Track 2.1","Track 2.2","Track 2.3"],"sleeve_notes":"SleeveNotes: id(1)","deleted":1,"artist_id":"Mike Smith","id":2,"recorded":"1989-02-02","title":"DJ Mix 2","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 2"},{"cpac__id":"id\u00003","tracks":["Track 3.1","Track 3.2","Track 3.3"],"sleeve_notes":"","deleted":1,"artist_id":"Mike Smith","id":3,"recorded":"1989-03-02","title":"DJ Mix 3","copyright":["Label A","Label B"],"cpac__display_name":"DJ Mix 3"},{"cpac__id":"id\u00005","tracks":["Hit Tune","Hit Tune 3","Hit Tune II"],"sleeve_notes":"","deleted":0,"artist_id":"Adam Smith","id":5,"recorded":"2002-05-21","title":"Greatest Hits","copyright":["Label B"],"cpac__display_name":"Greatest Hits"}]}
END_FILTER_ALBUM

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {}, $default_album_page, 'no args');

# page : the pager page number : defaults to 1

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 1}, $default_album_page, 'page one');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2}, {'total' => 5, 'rows' => []}, 'excess page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => -1}, $default_album_page, 'negative page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 0}, $default_album_page, 'page zero');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 'abc'}, $default_album_page, 'text page');

# limit : the number of records in a page : defaults to 10

my $two_records = Storable::dclone($default_album_page);
splice @{$two_records->{rows}}, 2 ;
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {limit => 2}, $two_records, 'limit of two');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {limit => 20}, $default_album_page, 'excess limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {limit => -5}, $default_album_page, 'negative limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {limit => 0}, $default_album_page, 'zero limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {limit => 'abc'}, $default_album_page, 'text limit');

# page and limit together - both required : false is reset as default

my $page_and_limit = Storable::dclone($default_album_page);
$page_and_limit->{rows} = [ @{$page_and_limit->{rows}}[2,3] ];
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2, limit => 2}, $page_and_limit, 'page and limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => -1, limit => 2}, $default_album_page, 'two recs neg page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 0, limit => 2}, $two_records, 'two recs zero page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 100, limit => 2}, {'total' => 5, 'rows' => []}, 'two recs excess page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 'abc', limit => 2}, $default_album_page, 'two recs text page');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 1, limit => 20}, $default_album_page, 'one page excess limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2, limit => 20}, {'total' => 5, 'rows' => []}, 'page two excess limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2, limit => -5}, $default_album_page, 'page two neg limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 1, limit => 0}, $default_album_page, 'one page zero limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2, limit => 0}, {'total' => 5, 'rows' => []}, 'page two zero limit');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {page => 2, limit => 'abc'}, $default_album_page, 'page two text limit');

# sort : single column to sort by : defaults to the PK (id, for album)

my $sort_recorded = Storable::dclone($default_album_page);
$sort_recorded->{rows} = [ @{$sort_recorded->{rows}}[0,1,2,4,3] ];
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'recorded'}, $sort_recorded, 'sort by recorded');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'foobar'}, $default_album_page, 'sort by nonexistent');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'tracks'}, $default_album_page, 'sort by multi rel');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => ''}, $default_album_page, 'sort by unspecified');

my $sort_fk = Storable::dclone($default_album_page);
$sort_fk->{rows} = [ @{$sort_fk->{rows}}[4,3,0,1,2] ];
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'artist_id'}, $sort_fk, 'sort by sfy FK');

# dir : direction of sort, ASC or DESC : defaults to ASC

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {dir => 'ASC'}, $default_album_page, 'sort ASC');

my $sort_desc = Storable::dclone($default_album_page);
$sort_desc->{rows} = [ reverse @{$sort_desc->{rows}} ];
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {dir => 'DESC'}, $sort_desc, 'sort DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {dir => ''}, $default_album_page, 'empty sort');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {dir => 'foobar'}, $default_album_page, 'nonsense sort');

# sort and dir together

my $sort_rec_desc = Storable::dclone($default_album_page);
$sort_rec_desc->{rows} = [ @{$sort_rec_desc->{rows}}[3,4,2,1,0] ];
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'recorded', dir => 'DESC'}, $sort_rec_desc, 'sort by recorded DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/track/list', {sort => 'parent_album', dir => 'DESC'}, $sorted_track_page, 'sort by FK DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'foobar', dir => 'DESC'}, $sort_desc, 'sort by nonexistent DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'tracks', dir => 'DESC'}, $sort_desc, 'sort by multi rel DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => '', dir => 'DESC'}, $sort_desc, 'sort by unspecified DESC');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'foobar', dir => ''}, $default_album_page, 'sort by nonexistent, empty dir');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'tracks', dir => ''}, $default_album_page, 'sort by FK multi, empty dir');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => '', dir => ''}, $default_album_page, 'empty dir and empty sort');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'foobar', dir => 'foobar'}, $default_album_page, 'sort by nonexistent, nonsense dir');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => 'tracks', dir => 'foobar'}, $default_album_page, 'sort by FK multi, nonsense dir');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {sort => '', dir => 'foobar'}, $default_album_page, 'empty sort, nonsense dir');

# filter fields : build a WHERE LIKE clause but should not work on numerics

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.id' => ''}, {total => 0, rows => []}, 'filter none');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.title' => ''}, $default_album_page, 'filter none');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter. ' => ''}, $default_album_page, 'filter col space');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.' => ''}, $default_album_page, 'filter col missing');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.foobar' => ''}, $default_album_page, 'filter col nonexistent');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.id' => '%'}, {total => 0, rows => []}, 'filter id by %');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.title' => '%'}, $default_album_page, 'filter none');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.id' => '!'}, {total => 0, rows => []}, 'filter to none');

my $case_correct = Storable::dclone($default_album_page);
$case_correct->{rows} = [ @{$case_correct->{rows}}[0,1,2] ];
$case_correct->{total} = 3;
$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.title' => 'Mix'}, $case_correct, 'filter case correct');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.title' => 'mix'}, $case_correct, 'filter case insensitive');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.artist_id' => '%'}, {total => 0, rows => []}, 'emtpy filter by fk');

$mech->ajax_ok('/site/default/schema/dbic/source/album/list', {'cpac_filter.artist_id' => 'Smith'}, $filtered_album_page, 'filter by fk');

