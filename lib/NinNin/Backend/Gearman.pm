package NinNin::Backend::Gearman;
use Any::Moose;
extends qw/NinNin::Backend/;

use Gearman::Worker;
use Gearman::Client;
use Data::MessagePack;

has gearman_options => ( is => 'rw', isa => 'HashRef', required => 1 );

has worker          => ( is => 'rw', isa => 'Gearman::Worker',   lazy => 1, builder => '_build_worker',
                         handles => [ qw/work/ ] );
has client          => ( is => 'rw', isa => 'Gearman::Client',   lazy => 1, builder => '_build_client' );
has packer          => ( is => 'rw', isa => 'Data::MessagePack', lazy => 1, builder => '_build_packer' );

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    my ($gearman_options) = @_;

    return $class->$orig({ gearman_options => $gearman_options });
};

override dispatch => sub {
    my ($self, $job) = @_;

    $self->client->dispatch_background( 'ninnin' => $self->packer->pack( $job->to_hash ) );
};

sub ninnin {
    my ($self, $packed_job) = @_;
    my $unpacked = $self->packer->unpack( $packed_job->arg );

    NinNin::Job->new( $unpacked )->run;
}

sub register_function {
    my ($self) = @_;
    $self->worker->register_function(
        'ninnin' => sub {
            $self->ninnin( @_ );
        }
    );
}

sub _build_worker {
    my ($self) = @_;
    my $worker = Gearman::Worker->new(%{ $self->gearman_options });
    return $worker;
}

sub _build_client {
    my ($self) = @_;
    my $client = Gearman::Client->new(%{ $self->gearman_options });
    return $client;
}

sub _build_packer {
    my ($self) = @_;
    return Data::MessagePack->new();
}

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

NinNin::Backend::Gearman - gearman backend(worker/client)

=head1 SYNOPSIS

  use NinNin;
  use NinNin::Backend::Gearman;

  # run gearman worker pool

  my $worker = NinNin::Backend::Gearman->new({
    job_servers => $job_servers,
  });
  $worker->register_function;
  $worker->work while 1;

  # or merge in your own gearman worker pool
  use Gearman::Worker;
  my $worker = Gearman::Worker->new(
    job_servers => $job_servers,
  );
  $worker->register_function( ...your functions... );

  my $ninnin_backend = NinNin::Backend::Gearman->new;
  $ninnin_backend->worker( $worker );
  $ninnin_register_function;

  $worker->work while 1;

=head1 DESCRIPTION

=head1 AUTHOR

mash E<lt>o.masakazu@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
