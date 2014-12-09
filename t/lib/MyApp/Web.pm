package MyApp::Web;
use strict;
use warnings;
use utf8;

use parent qw/MyApp Amon2::Web/;

use MyApp::Web::C::Root;
use Mock::Text::Xslate;

sub create_view { Mock::Text::Xslate->new }

sub dispatch {
    my $self = shift;
    return MyApp::Web::C::Root->index($self);
}


1;
