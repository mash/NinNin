use Test::More;
use strict;
use warnings;

use NinNin;
use NinNin::Backend::Synchronous;

NinNin->setup({
    backend => NinNin::Backend::Synchronous->new
});

ninnin(
    sub {
        my (@args) = @_;

        Test::More::is_deeply( \@args, [ 'Hello', 'World!' ] );
    },
    ('Hello', 'World!')
);

done_testing 1;
