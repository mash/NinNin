package NinNin::Job;
use Any::Moose;

has code   => ( is => 'rw', isa => 'Str',      required => 1 );
has args   => ( is => 'rw', isa => 'ArrayRef', required => 1 );

has subref => ( is => 'rw', isa => 'CodeRef', lazy => 1, builder => '_build_subref' );

sub to_hash {
    my ($self) = @_;
    return {
        code => $self->code,
        args => $self->args,
    };
}

sub run {
    my ($self) = @_;
    $self->subref->( @{ $self->args } );
}

sub _build_subref {
    my ($self) = @_;

    my $sub = eval "sub ".$self->code;
    warn $@
        if $@;

    return $sub;
}

__PACKAGE__->meta->make_immutable;
