use Test::More;
use strict;
use warnings;

use NinNin;
use NinNin::Backend::Synchronous;

NinNin->setup({
    backend => NinNin::Backend::Synchronous->new
});

my $background_job = ninnin(
    sub {
        my (@args) = @_;

        Test::More::is_deeply( \@args, [ 'Hello', 'World!' ] );
    },
);
$background_job->( 'Hello', 'World!' );

done_testing 1;
