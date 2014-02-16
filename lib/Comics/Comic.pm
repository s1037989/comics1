package Comics::Comic;
use Mojo::Base -base;
use Mojo::Util qw(decamelize slurp md5_sum);
use overload '""' => sub { shift->name }, fallback=>1;

has core => sub { shift->{core} };
has name => 'Unnamed';
has link => '';
has moniker => sub { decamelize(((split '::', ref shift))[-1]) };

sub size {
  my $self = shift;
say $self->img;
  $self->img->each(sub{$_ = -s $_});
}
sub sum {
  my $self = shift;
  $self->img->each(sub{$_ = md5_sum slurp $_});
}
sub url {
  my $self = shift;
  $self->core->format($self->link);
}
sub img {
  my $self = shift;
  my $moniker = $self->moniker;
  my $home = Mojo::Home->new(Mojo::Path->new(Mojo::Home->new->detect(__PACKAGE__).'/')->merge('public/')->merge($self->core->current));
  Mojo::Collection->new(grep { $_->parts->[-1] =~ /$moniker/ } map { Mojo::Path->new("$home/$_") } @{$home->list_files});
}

1;
