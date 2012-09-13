use strict;
use warnings;
use Test::More;

use Test::TCP;
use Test::RedisServer;
use Proc::Guard;
use Time::HiRes qw/sleep/;

use NinNin;
use NinNin::Backend::Redis;

my $redis_server;
eval {
    $redis_server = Test::RedisServer->new
};
if ($@) {
    plan skip_all => 'redis-server is required to run this test';
}

my $worker = proc_guard sub {
    my $worker = NinNin::Backend::Redis->new( $redis_server->connect_info );
    $worker->work while 1;
};

NinNin->setup({
    backend => NinNin::Backend::Redis->new( $redis_server->connect_info )
});

my $background_job = ninnin(
    sub {
        my (@args) = @_;

        Test::More::is_deeply( \@args, [ 'Hello', 'World!' ] );
    },
);
$background_job->( 'Hello', 'World!' );

sleep 0.1;

done_testing;
