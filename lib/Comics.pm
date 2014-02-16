package Comics;
use Mojo::Base 'Mojolicious';

use Comics::Core;

has comics => sub { Comics::Core->new(config => shift->config) };

sub startup {
  my $self = shift;

  $self->app->hook(before_render => sub {
    my ($self, $args) = @_;
    # Implement this hook for development mode only 
    return unless $self->app->mode eq 'development';   
    # Make sure we are rendering the exception template
    return unless my $template = $args->{template};
    if ( $template eq 'exception' ) {
      # Switch to JSON rendering if content negotiation allows it
      $args->{json} = {exception => $self->stash('exception')} if scalar $self->req->headers->header('User-Agent') =~ /^curl|^Mojolicious/;
    } elsif ( $template eq 'not_found' ) {
      # Switch to JSON rendering if content negotiation allows it
      $args->{json} = {not_found => $self->stash('not_found')} if scalar $self->req->headers->header('User-Agent') =~ /^curl|^Mojolicious/;
    }
  });
  $self->app->hook(after_render => sub {
    my ($self, $args) = @_;
    # Implement this hook for development mode only 
    return unless $self->app->mode eq 'development';   
    $$args .= "\n" if scalar $self->req->headers->header('User-Agent') =~ /^curl|^Mojolicious/;
  });

  $self->plugin(config => {default=>{}});

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/:date/:do', date => qr/now|today|tomorrow|yesterday|first|last|random|\d{8}/, do=>['get'])->to('example#list', date=>'now', do=>'')->name('comics');
}

1;
