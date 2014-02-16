package Comics::Example;
use Mojo::Base 'Mojolicious::Controller';

# This action will render a template
sub welcome {
  my $self = shift;

  # Render template "example/welcome.html.ep" with message
  $self->render(msg => 'Welcome to the Mojolicious real-time web framework!');
}

sub list {
  my $self = shift;
  $self->app->comics->date($self->param('date'));
#  qx{$webroot/comics.sh $download} if $self->param('get');
  $self->stash(comics => $self->app->comics);
}

1;
