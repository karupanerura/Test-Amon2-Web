use strict;
use Test::More 0.98;
use Test::Amon2::Web;

use File::Basename ();
use File::Spec;
use lib File::Spec->catdir(File::Basename::dirname(__FILE__), 'lib');
use MyApp::Web;

my $t = Test::Amon2::Web->new(web_context_class => 'MyApp::Web');

subtest method => sub {
    is $t->create_psgi_env(path => '/')->{REQUEST_METHOD},                   'GET';
    is $t->create_psgi_env(method => 'POST', path => '/')->{REQUEST_METHOD}, 'POST';
};

subtest scheme => sub {
    is $t->create_psgi_env(path => '/')->{'psgi.url_scheme'},                    'http';
    is $t->create_psgi_env(scheme => 'https', path => '/')->{'psgi.url_scheme'}, 'https';
};

subtest host => sub {
    is $t->create_psgi_env(path => '/')->{HTTP_HOST},                    'localhost';
    is $t->create_psgi_env(host => 'foo.net', path => '/')->{HTTP_HOST}, 'foo.net';
};

subtest port => sub {
    is $t->create_psgi_env(path => '/')->{HTTP_HOST},                'localhost';
    is $t->create_psgi_env(port => 12345, path => '/')->{HTTP_HOST}, 'localhost:12345';
};

subtest path => sub {
    is $t->create_psgi_env(path => '/')->{PATH_INFO},           '/';
    is $t->create_psgi_env(path => '/foo')->{PATH_INFO},        '/foo';
    is $t->create_psgi_env(path => '/bar/')->{PATH_INFO},       '/bar/';
    is $t->create_psgi_env(path => '/?q=1')->{PATH_INFO},       '/';
    is $t->create_psgi_env(path => '/foo?q=1')->{PATH_INFO},    '/foo';
    is $t->create_psgi_env(path => '/bar/?q=1')->{PATH_INFO},   '/bar/';
    is $t->create_psgi_env(path => '/?q=1')->{REQUEST_URI},     '/?q=1';
    is $t->create_psgi_env(path => '/foo?q=1')->{REQUEST_URI},  '/foo?q=1';
    is $t->create_psgi_env(path => '/bar/?q=1')->{REQUEST_URI}, '/bar/?q=1';
};

subtest query => sub {
    is $t->create_psgi_env(path => '/',         query => [a => 'b'])->{REQUEST_URI}, '/?a=b';
    is $t->create_psgi_env(path => '/',         query => {a => 'b'})->{REQUEST_URI}, '/?a=b';
    is $t->create_psgi_env(path => '/?foo=bar', query => [a => 'b'])->{REQUEST_URI}, '/?a=b';
    is $t->create_psgi_env(path => '/?foo=bar', query => {a => 'b'})->{REQUEST_URI}, '/?a=b';
};

is $t->create_psgi_env(path => '/', headers => [Foo => 'bar'])->{HTTP_FOO}, 'bar', 'headers';

subtest content => sub {
    for my $content_type (qw!application/x-www-form-urlencoded multipart/form-data!) {
        my $gen = sub { Plack::Request->new($t->create_psgi_env(@_))->body_parameters };
        subtest $content_type => sub {
            diag 'SKIP: HTTP::Body::Builder::MultiPart is maybe broken.' xor return pass 'SKIP' if $content_type eq 'multipart/form-data';
            is $gen->(path => '/',     headers => ['Content-Type' => $content_type], content => [a => 'b'])->get('a'), 'b';
            is $gen->(path => '/',     headers => ['Content-Type' => $content_type], content => {a => 'b'})->get('a'), 'b';
            is $gen->(path => '/?a=v', headers => ['Content-Type' => $content_type], content => [a => 'b'])->get('a'), 'b';
            is $gen->(path => '/?a=v', headers => ['Content-Type' => $content_type], content => {a => 'b'})->get('a'), 'b';
        };
    }
};

done_testing;

