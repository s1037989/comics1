package Comics::Path;
use Mojo::Base -base;

has comics => sub { shift->{comics} };
has public => sub { Mojo::Home->new(Mojo::Home->new->detect(ref shift)->rel_dir('public')) };

sub date {
  my $self = shift;
  $self->public->rel_dir($self->comics->date);
}

sub prev {
  my $self = shift;
  $self->public->rel_dir($self->comics->prev);
}

1;
