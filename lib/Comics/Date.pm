package Comics::Date;
use Mojo::Base -base;
use overload
  bool => sub {1},
  '""' => sub { shift->to_string },
  fallback => 1;

use Date::Manip;

#  $self->comics->prev;                 # 20140215
#  $self->comics->prev->to_string;      # 20140215
#  $self->comics->prev->to_abs;         # /d/w/m/c/p/20140215
#  $self->comics->prev->list;           # qw/f z d/
#  $self->comics->prev->frazz;          # Frazz
#  $self->comics->prev->frazz->img;     # /d/w/m/c/p/20140215/frazz.gif

has today => UnixDate(ParseDate('now'), '%Y%m%d');
has first => '20030720';
has req => '';
has _date => '';

sub date {
  my ($self, $date) = @_;
  $self->_date(UnixDate(ParseDate($self->req($self->can($date) ? $self->$date : $date), '%Y%m%d'))) if $date;
  $self;
}

sub next {
  my $self = shift;
  local $_ = UnixDate(DateCalc($self->_date, "+ 1 day"), '%Y%m%d');
  $self->_date($_ > $self->today ? undef : $_);
  $self;
}

sub prev {
  my $self = shift;
  local $_ = UnixDate(DateCalc($self->_date, "- 1 day"), '%Y%m%d');
  $self->_date($_ < $self->first ? undef : $_);
  $self;
}

sub prevweek {
  my $self = shift;
  local $_ = UnixDate(DateCalc($self->_date, "- 7 day"), '%Y%m%d');
  $self->_date($_ < $self->first ? undef : $_);
  $self;
}

sub prevweek {
  my $self = shift;
  local $_ = UnixDate(DateCalc($self->_date, "- 7 day"), '%Y%m%d');
  $self->_date($_ < $self->first ? undef : $_);
  $self;
}

sub random {
  my $self = shift;
  $self->_date($self->comics->
}
#basename ((shuffle(grep { -d $_ } glob(shift->config->{comicsdir}."/2*")))[0]) }

1;
