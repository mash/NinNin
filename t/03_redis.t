use strict;
use warnings;
use Test::More;

use Test::TCP;
use Test::RedisServer;
use Proc::Guard;
use Time::HiRes qw/sleep/;

use NinNin;
use NinNin::Backend::Redis;

my $port = empty_port;

my $redis_server;
eval {
    $redis_server = Test::RedisServer->new( conf => {
        port => $port,
    });
};
if ($@) {
    plan skip_all => 'redis-server is required to run this test';
}

my $worker = proc_guard sub {
    my $worker = NinNin::Backend::Redis->new(
        server => "127.0.0.1:$port",
    );
    $worker->work while 1;
};

NinNin->setup({
    backend => NinNin::Backend::Redis->new(
        server => "127.0.0.1:$port",
    )
});

ninnin(
    sub {
        my (@args) = @_;

        Test::More::is_deeply( \@args, [ 'Hello', 'World!' ] );
    },
    ('Hello', 'World!')
);

sleep 0.1;

done_testing;
