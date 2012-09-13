use Test::More;
use strict;
use warnings;

use Proc::Guard;
use Test::TCP qw/empty_port wait_port/;
use Gearman::Server;
use Time::HiRes qw/sleep/;

use NinNin;
use NinNin::Backend::Gearman;

note 'launch gearmand';

my $gearmand_port = empty_port();
my $gearmand = proc_guard(
    sub {
        Gearman::Server->new( port => $gearmand_port );
        Danga::Socket->EventLoop();
    }
);
wait_port( $gearmand_port );

note "gearmand launched on $gearmand_port";

my $job_servers = [ "127.0.0.1:$gearmand_port" ];

note 'launch gearman worker';

my $gearman_worker = proc_guard(
    sub {
        my $gearman = NinNin::Backend::Gearman->new({
            job_servers => $job_servers,
        });
        $gearman->register_function;
        $gearman->work while 1;
    }
);

NinNin->setup({
    backend => NinNin::Backend::Gearman->new({
        job_servers => $job_servers,
    })
});

my $background_job = ninnin(
    sub {
        my (@args) = @_;

        Test::More::is_deeply( \@args, [ 'Hello', 'World!' ] );
    },
);
$background_job->( 'Hello', 'World!' );

sleep 0.1; # async

done_testing 1;
