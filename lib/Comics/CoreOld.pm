package Comics::Core;
use Mojo::Base -base;
use overload bool => sub {1}, '""' => sub { shift->to_string }, fallback => 1;

use Mojo::Util qw/camelize decamelize/;

use Comics::Path;

use Date::Manip;
use List::Util 'shuffle';
use File::Basename;

has config => sub { shift->{config} };
#has list => sub { [] };

has today => UnixDate(ParseDate('now'), '%Y%m%d');    
has first => '20030720';
has _date => '';

#  $self->comics->prev;			# 20140215
#  $self->comics->prev->to_string;	# 20140215
#  $self->comics->prev->to_abs;		# /d/w/m/c/p/20140215
#  $self->comics->prev->list;		# qw/f z d/
#  $self->comics->prev->frazz;		# Frazz
#  $self->comics->prev->frazz->img;	# /d/w/m/c/p/20140215/frazz.gif

sub date {
  my ($self, $date) = @_;
  $self->_date(UnixDate(ParseDate($self->can($date) ? $self->$date : $date), '%Y%m%d')) if $date;
  $self;
}
sub prev {
  my $self = shift;
  $self->_date(UnixDate(ParseDate($self->can($date) ? $self->$date : $date), '%Y%m%d')) if $date;
  $self;
}

sub datefull { UnixDate(ParseDate(shift->date), '%A, %B %d, %Y') }
sub next { my $self = shift; local $_ = UnixDate(DateCalc($self->date, "+ 1 day"), '%Y%m%d'); $_ > $self->today ? undef : $_ }
sub prev { my $self = shift; local $_ = UnixDate(DateCalc($self->date, "- 1 day"), '%Y%m%d'); $_ < $self->first ? undef : $_ }
sub prevweek { my $self = shift; local $_ = UnixDate(DateCalc($self->date, "- 7 day"), '%Y%m%d'); $_ < $self->first ? undef : $_ }
sub random { basename ((shuffle(grep { -d $_ } glob(shift->config->{comicsdir}."/2*")))[0]) }

sub new {
  my $self = shift->SUPER::new(@_);
  my $l = Mojo::Loader->new;
  for my $module ( (map { "Comics::Comic::".camelize($_) } @{$self->config->{order}}), @{$l->search('Comics::Comic')} ) {
    my $M = (((split '::', $module))[-1]);
    my $m = decamelize($M);
    $self->{comics}->{$m} and next;
    if ( my $e = $l->load($module) ) {
      die ref $e ? "Exception: $e" : 'Not found!';
    }
    push @{$self->list}, $m;
    $self->{comics}->{$m} = $module->new(comics => $self);
    eval "sub $m { shift->{comics}->{$m} }";
  }
  $self;
}

sub path {
  my $self = shift;
  Comics::Path->new(comics => $self);
}

#sub list { # List date's comics
#  my $self = shift;
#  $self->comics->path->date->list_files;
#  $self->comics->date->path->list_files;
#  $self->comics->prev->path->list_files;

#}

sub pull {
  my ($self, $date) = @_;

  $date = $self->date($date);
  say $self->datefull;
  say $self->path->prev;

  # Remove comics that are too small to be comics and empty comic folders
  # test -d $COMICDIR && find $COMICDIR -type f -name "*.gif" -size -5000c | xargs -r rm -f
  #-d $self->comics->path->date and unlink $_ foreach grep { /\.gif$/ && -s $_ <= 5000 } $self->comics->list
  # test -d $COMICDIR && find $COMICDIR -empty | xargs -r rmdir
  #-d $self->comics->path->date and unlink $self->comics->path->date unless $self->comics->list;
  # Remove comics that are the same as the previous day
  # test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prev/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prev/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
  # test -d $COMICDIR && ls -1 $COMICDIR/* | while read i; do j=$PREVDIR/${i##*/}; is=$(stat -c %s $i); js=$(stat -c %s $j); [ $js -eq $is ] && rm -f $i; done
  # Or the previous week
  # test -d $COMICDIR && md5sum $COMICDIR/* | sed "s/$date/$prevweek/" | md5sum -c - 2>/dev/null | grep OK$ | sed "s/$prevweek/$date/;s/: OK$//" | grep gif$ | xargs -r rm -f
  # test -d $COMICDIR && ls -1 $COMICDIR/* | while read i; do j=$PREVWEEKDIR/${i##*/}; is=$(stat -c %s $i); js=$(stat -c %s $j); [ $js -eq $is ] && rm -f $i; done
  # mkdir -p $COMICDIR
  # touch $COMICDIR

  #$self->comics->$_->pull foreach $self->comics->list;

  #chown -R www-data.www-data $COMICDIR
}

1;
