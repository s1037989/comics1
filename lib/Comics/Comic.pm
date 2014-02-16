package Comics::Comic;
use Mojo::Base -base;
use Mojo::Util 'decamelize';
use overload '""' => sub { shift->name }, fallback=>1;

has name => 'Unnamed';
has link => '';
has moniker => sub { decamelize(((split '::', ref shift))[-1]) };

sub url {
  my $self = shift;
  $self->{comics}->__date->format($self->link);
}
sub img {
  my $self = shift;
  my $moniker = $self->moniker;
  my $home = Mojo::Home->new(Mojo::Path->new(Mojo::Home->new->detect($self).'/')->merge('public/')->merge($self->{comics}->__date));
  Mojo::Collection->new(grep { $_->parts->[-1] =~ /$moniker/ } map { Mojo::Path->new("$home/$_") } @{$home->list_files});
}

1;
