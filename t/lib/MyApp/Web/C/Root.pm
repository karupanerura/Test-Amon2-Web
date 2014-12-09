package MyApp::Web::C::Root;
use strict;
use warnings;
use utf8;

sub index :method {
    my ($class, $c) = @_;
    return $c->render('index.tx' => {});
}

1;
__END__
