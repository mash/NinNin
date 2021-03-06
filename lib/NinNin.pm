package NinNin;
use strict;
use warnings;
use parent qw/Exporter/;
our $VERSION = '0.01';
our @EXPORT = qw/ninnin/;

use NinNin::Job;

use B::Deparse;
my $deparser = B::Deparse->new;

my $BROKER;

sub setup {
    my ($class, $args) = @_;
    my $backend = $args->{ backend };

    $BROKER = sub {
        $backend->dispatch( @_ );
    };
}

sub ninnin {
    my ($sub) = @_;
    die "setup backend first" unless $BROKER;

    my $code = $deparser->coderef2text( $sub );

    return sub {
        my (@args) = @_;
        my $job = NinNin::Job->new(
            code => $code,
            args => \@args,
        );
        $BROKER->( $job );
    };
}

1;
__END__

=head1 NAME

NinNin - casual background processing

=head1 SYNOPSIS

  use NinNin;
  use NinNin::Backend::Gearman;

  # run gearman worker pool beforehand
  # my $worker = NinNin::Backend::Gearman->new({
  #   job_servers => $job_servers,
  # });
  # $worker->register_function;
  # $worker->work while 1;

  NinNin->setup({
    backend => NinNin::Backend::Gearman->new({
      job_servers => [ '127.0.0.1:4730' ]
    })
  });

  my $background_job = ninnin(
    sub {
      my (@args) = @_;
      # run in gearman worker
      # ...heavy work...
    },
  );
  $background_job->( @args ) # run background job with argument


=head1 DESCRIPTION

NinNin is a casual background processing framework

=head1 AUTHOR

mash E<lt>o.masakazu@gmail.comE<gt>

Daisuke Murase <typester@cpan.org>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
