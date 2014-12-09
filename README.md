# NAME

Test::Amon2::Web - It's new $module

# SYNOPSIS

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

# DESCRIPTION

Test::Amon2::Web is ...

# LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

karupanerura <karupa@cpan.org>
