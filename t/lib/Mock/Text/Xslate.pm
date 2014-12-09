package Mock::Text::Xslate;
use strict;
use warnings;
use utf8;

use Data::Dumper ();

sub new { bless {}, __PACKAGE__ }

sub render { Data::Dumper::Dumper(@_) }

1;
__END__
