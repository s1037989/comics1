package Comics::Command::pull;
use Mojo::Base 'Mojolicious::Command';

has description => 'Run code against application.';
has usage => sub { shift->extract_usage };

sub run {
  my ($self, $date) = @_;

  $self->app->comics->date($date)->pull;
}

1;
