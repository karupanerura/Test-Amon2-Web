package Test::Amon2::Web;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Carp qw/croak/;
use URI;
use Scalar::Util qw/blessed/;
use HTTP::Headers;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use HTTP::Body::Builder::MultiPart;
use HTTP::Body::Builder::UrlEncoded;

sub new {
    my $class = shift;
    return bless {
        default_content_type => 'application/x-www-form-urlencoded',
        default_scheme       => 'http',
        default_host         => 'localhost',
        default_port         => 80,
        agent                => "$class/$VERSION",
        web_context_class    => 'Amon2::Web',
        @_,
    } => $class;
}

sub emulate_request {
    my $self = shift;
    my $env  = $self->create_psgi_env(@_);
    my $res  = $self->{web_context_class}->handle_request($env);
    return HTTP::Response->from_psgi($res);
}

sub create_context {
    my $self = shift;
    my $req  = $self->create_request(@_);
    return $self->{web_context_class}->new(request => $req);
}

sub create_request {
    my $self = shift;
    my $env  = $self->create_psgi_env(@_);
    return $self->{web_context_class}->create_request($env);
}

sub create_psgi_env {
    my ($self, %args) = @_;
    my $method  = exists $args{method} ? uc $args{method} : 'GET';
    my $uri     = $args{uri}     || $self->_create_uri(@args{qw/scheme host port path query/});
    my $headers = $args{headers} || [];
    my $content = $args{content};

    $headers = HTTP::Headers->new(@$headers) unless blessed $headers;
    if (defined $content) {
        my $content_type = $headers->header('Content-Type');
        if (blessed $content && $content->isa('Hash::MultiValue')) {
            my $builder = $self->_create_body_builder($content_type);
            $content->each(sub {
                my ($key, $value) = @_;
                $builder->add_content($key, $value);
            });
            $content = $builder->as_string();
        }
        elsif (ref $content eq 'HASH') {
            my $builder = $self->_create_body_builder($content_type);
            for my $key (keys %$content) {
                $builder->add_content($key, $content->{$key});
            }
            $content = $builder->as_string();
        }
        elsif (ref $content eq 'ARRAY') {
            my $builder = $self->_create_body_builder($content_type);
            my @content = @$content;
            while ( my ($key, $value) = splice @content, 0, 2 ) {
                $builder->add_content($key, $value);
            }
            $content = $builder->as_string();
        }
        else {
            # nothing to do.
        }
    }

    return HTTP::Request->new($method, $uri, $headers, $content)->to_psgi;
}

sub _create_body_builder {
    my ($self, $content_type) = @_;
    $content_type ||= $self->{default_content_type};
    for my $builder_class (qw/HTTP::Body::Builder::UrlEncoded HTTP::Body::Builder::MultiPart/) {
        return $builder_class->new if $builder_class->content_type eq $content_type;
    }
    croak "You cannot create body builder with $content_type.";
}

sub _create_uri {
    my ($self, $scheme, $host, $port, $path, $query) = @_;
    $scheme ||= $self->{default_scheme};
    $host   ||= $self->{default_host};
    $port   ||= $self->{default_port};

    my $uri = URI->new();
    $uri->scheme($scheme);
    $uri->host($host);
    $uri->port($port);
    $uri->path_query($path);
    $uri->query_form($query) if defined $query;
    return $uri;
}

1;
__END__

=encoding utf-8

=head1 NAME

Test::Amon2::Web - It's new $module

=head1 SYNOPSIS

    use Test::More;
    use Test::Amon2::Web;
    use Test::Mock::Guard;
    use MyApp::Web;
    use MyApp::Web::C::Root;

    my $t = Test::Amon2::Web->new(web_context_class => 'MyApp::Web');

    subtest 'template' => sub {
        my $c     = $t->create_context(path => '/');
        my $guard = $c->context_guard();

        my ($tmpl, $param);
        my $mock = Test::Mock::Guard->new(MyApp::Web => {
            render => do {
                my $super = MyApp::Web->can('render');
                sub {
                    my $self = shift;
                    ($tmpl, $param) = @_;
                    return $self->$super(@_);
                }
            }
        });
        MyApp::Web::C::Root->index($c);
        is        $tmpl,  'index.tx', 'used index.tx.';
        is_deeply $param, {
            foo => 'bar',
        };
    };

    subtest 'end to end' => sub {
        my $res = $t->emulate_request(path => '/');
        is $res->code, 200, '200 OK';
        like $res->header('Content-Type'), qr!text/html!, 'text/html';
    };

    done_testing();

=head1 DESCRIPTION

Test::Amon2::Web is ...

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut

