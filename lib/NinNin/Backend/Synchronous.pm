package NinNin::Backend::Synchronous;
use Any::Moose;
extends qw/NinNin::Backend/;

override dispatch => sub {
    my ($self, $job) = @_;

    $job->run;
};

__PACKAGE__->meta->make_immutable;
