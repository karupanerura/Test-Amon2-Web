use strict;
use Test::More 0.98;
use Test::Amon2::Web;

use File::Basename ();
use File::Spec;
use lib File::Spec->catdir(File::Basename::dirname(__FILE__), 'lib');
use MyApp::Web;

my $t = Test::Amon2::Web->new(web_context_class => 'MyApp::Web');

my $res = $t->emulate_request(path => '/');
isa_ok $res, 'HTTP::Response';

done_testing;
