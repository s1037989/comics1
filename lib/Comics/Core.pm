package Comics::Core;
use Mojo::Base -base;
use overload '""' => sub { shift->to_string }, fallback=>1;

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
has current => '';
has _ordered => sub { [] };
has all => sub { Mojo::Collection->new(@{shift->_ordered}) };

sub datefull { shift->current->format('%A, %B %d, %Y') }
sub date { my ($self, $date) = @_; $self->current($date ? Date::Simple::D8->new($date) : Date::Simple::D8->new); $self; };
sub first { my $self = shift; $self->current(Date::Simple::D8->new($self->_first)); $self; }
sub today { my $self = shift; $self->current(Date::Simple::D8->new); $self; }
sub next { my $self = shift; $self->current($self->current+1); $self; }
sub prev { my $self = shift; $self->current($self->current-1); $self; }
sub prevweek { my $self = shift; $self->current($self->current-7); $self; }
sub random { my $self = shift; $self->current(Mojo::Collection->new(Date::Range->new($self->first->current, $self->today->current)->dates)->shuffle->[0]); $self; }

sub to_string { shift->current }

sub new {
  my $self = shift->SUPER::new(@_);
  $self->date;
  my $l = Mojo::Loader->new;
  for my $module ( (map { "Comics::Comic::".camelize($_) } @{$self->config->{order}}), @{$l->search('Comics::Comic')} ) {
    my $M = (((split '::', $module))[-1]);
    my $m = decamelize($M);
    $self->{_comics}->{$m} and next;
    if ( my $e = $l->load($module) ) {
      die ref $e ? "Exception: $e" : 'Not found!';
    }
    push @{$self->_ordered}, $self->{_comics}->{$m} = $module->new(core => $self);
    eval "sub $m { shift->{_comics}->{$m} }";
  }
  $self;
}

sub pull {
  my ($self) = @_;

  say $self->datefull;  

say $self->frazz->img;
  # Remove comics that are too small to be comics and empty comic folders
  # test -d $COMICDIR && find $COMICDIR -type f -name "*.gif" -size -5000c | xargs -r rm -f
  #-d $self->comics->path->date and unlink $_ foreach grep { /\.gif$/ && -s $_ <= 5000 } $self->comics->list
#  $self->all->grep(sub{/\.(gif|png|jpg)$/ && -s $_ < 5_000})->each(sub{say "Too small: $_"});
  # test -d $COMICDIR && find $COMICDIR -empty | xargs -r rmdir
  #-d $self->comics->path->date and unlink $self->comics->path->date unless $self->comics->list;
#  say "Empty: $self" if $self->all->size == 0;
  # Remove comics that are the same as the previous day
  # test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prev/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prev/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
  # test -d $COMICDIR && ls -1 $COMICDIR/* | while read i; do j=$PREVDIR/${i##*/}; is=$(stat -c %s $i); js=$(stat -c %s $j); [ $js -eq $is ] && rm -f $i; done
#  $self->all->each(sub{my $c = $_->moniker; say $self->prev->$c->size, $_->size;});
  # Or the previous week
  # test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prevweek/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prevweek/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
  # test -d $COMICDIR && ls -1 $COMICDIR/* | while read i; do j=$PREVWEEKDIR/${i##*/}; is=$(stat -c %s $i); js=$(stat -c %s $j); [ $js -eq $is ] && rm -f $i; done
#  $self->all->each(sub{my $c = $_->moniker; say $self->prevweek->$c->size, $_->size;});
  # mkdir -p $COMICDIR
  # touch $COMICDIR

  #$self->comics->$_->pull foreach $self->comics->list;

  #chown -R www-data.www-data $COMICDIR
}

1;
