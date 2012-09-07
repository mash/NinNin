package NinNin::Backend::Redis;
use Any::Moose;

extends 'NinNin::Backend';

use Redis;
use Data::MessagePack;

has redis_options => (
    is  => 'rw',
    isa => 'HashRef',
);

has _redis => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        Redis->new(
            encoding => undef,
            %{ $self->redis_options },
        );
    },
);

has _packer => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        Data::MessagePack->new;
    },
);

no Any::Moose;

sub BUILDARGS {
    my $self = shift;
    return { redis_options => @_ > 1 ? {@_} : $_[0] },
}

sub dispatch {
    my ($self, $job) = @_;
    $self->_redis->rpush('ninnin', $self->_packer->encode($job->to_hash));
}

sub ninnin {
    my ($self, $packed_job) = @_;

    my $unpacked = $self->_packer->decode($packed_job);
    NinNin::Job->new($unpacked)->run;
}

sub work {
    my ($self) = @_;

    my ($key, $packed_job) = $self->_redis->blpop('ninnin', 0);
    $self->ninnin($packed_job) if defined $packed_job;
}

__PACKAGE__->meta->make_immutable;

__END__
