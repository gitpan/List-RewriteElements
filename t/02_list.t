# -*- perl -*-
#$Id: 02_list.t 1110 2006-12-14 03:56:31Z jimk $
# t/02_list.t - test what happens when source is a list

use Test::More tests => 15;
use_ok( 'List::RewriteElements' );
use_ok( 'Cwd' );
use_ok( 'File::Temp', qw| tempdir | );
use_ok( 'Tie::File' );
use_ok( 'Carp' );
use lib ( "t/testlib" );
use_ok( 'IO::Capture::Stdout' );

my $lre;
my @lines;

$lre  = List::RewriteElements->new ( {
    list        => [ map {"$_\n"} (1..10) ],
    body_rule   => sub {
        my $record = shift;
        return (10 * $record);
    },
} );
isa_ok ($lre, 'List::RewriteElements');

my $cap = IO::Capture::Stdout->new();
$cap->start();
$lre->generate_output();
$cap->stop();
chomp( @lines = $cap->read() );
is($lines[0], q{10}, "First element of list is correct");
is($lines[-1], q{100}, "Last element of list is correct");

{
    my $cwd = cwd();
    
    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    my $output = "./output";
    $lre  = List::RewriteElements->new ( {
        list        => [ map {"$_\n"} (1..10) ],
        body_rule   => sub {
            my $record = shift;
            return (10 * $record);
        },
        output_file => $output,
    } );
    isa_ok ($lre, 'List::RewriteElements');

    $lre->generate_output();
    ok(-f $output, "Output file created");

    my @lines;
    tie @lines, 'Tie::File', $output;
    is($lines[0], q{10}, "First element of list is correct");
    is($lines[-1], q{100}, "Last element of list is correct");
    untie @lines;
    
    ok(chdir $cwd, 'changed back to original directory after testing');
}

