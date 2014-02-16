use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Comics');

#my $comics = Comics::Core->new; say $comics; say $comics->date->next->next->frazz->url; say $comics->next->frazz->url;

use Date::Simple::D8 ();
my $today = Date::Simple::D8->new;
my $random = Date::Simple::D8->new('20140210');

is $t->app->comics, $today;
is $t->app->comics->date("20140210"), $random;
is $t->app->comics, $random;
is $t->app->comics->date->next, $today+1;
is $t->app->comics->date->next->prev, $today;
is $t->app->comics->date("20140210")->next, $random+1;
is $t->app->comics, $random+1;
is $t->app->comics->frazz, "Frazz";

done_testing();
