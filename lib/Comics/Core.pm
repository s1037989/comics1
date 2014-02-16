package Comics::Core;
use Mojo::Base -base;
use overload '""' => sub { shift->to_string };

use Mojo::Loader;
use Mojo::Home;
use Mojo::Path;
use Mojo::Collection;
use Mojo::Util qw/camelize decamelize/;

use Date::Simple::D8 ();
use Date::Range;

has config => sub { shift->{config} || {} };
has agent => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/31.0.1650.63 Chrome/31.0.1650.63 Safari/537.36";
has _first => '20030720';
#has _date => '';
has __date => '';
has _ordered => sub { [] };
has all => sub { Mojo::Collection->new(@{shift->_ordered}) };

sub date { my ($self, $date) = @_; $self->__date($date || $self->_date ? Date::Simple::D8->new($date || $self->_date) : Date::Simple->new); $self; };
sub first { my $self = shift; $self->__date(Date::Simple::D8->new($self->_first)); $self; }
sub today { my $self = shift; $self->__date(Date::Simple::D8->new); $self; }
sub next { my $self = shift; $self->__date($self->__date+1); $self; }
sub prev { my $self = shift; $self->__date($self->__date-1); $self; }
sub prevweek { my $self = shift; $self->__date($self->__date-7); $self; }
sub random { my $self = shift; $self->__date(Mojo::Collection->new(Date::Range->new($self->first->__date, $self->today->__date)->dates)->shuffle->[0]); $self; }

sub to_string { shift->__date }

sub new {
  my $self = shift;
  my $date = shift;
  $self = $self->SUPER::new(@_);
  $self->date($date) if $date;
  my $l = Mojo::Loader->new;
  for my $module ( (map { "Comics::Comic::".camelize($_) } @{$self->config->{order}}), @{$l->search('Comics::Comic')} ) {
    my $M = (((split '::', $module))[-1]);
    my $m = decamelize($M);
    $self->{_comics}->{$m} and next;
    if ( my $e = $l->load($module) ) {
      die ref $e ? "Exception: $e" : 'Not found!';
    }
    push @{$self->_ordered}, $self->{_comics}->{$m} = $module->new(comics => $self);
    eval "sub $m { shift->{_comics}->{$m} }";
  }
  $self;
}

1;
