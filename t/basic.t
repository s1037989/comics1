use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Comics');
#$t->get_ok('/')->status_is(200)->content_like(qr/Mojolicious/i);
is ref $t->app, 'Comics';

done_testing();
