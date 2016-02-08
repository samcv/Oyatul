#!perl6

use v6;

use Test;


use Oyatul;

use lib $*PROGRAM.parent.child('lib').Str;

my $layout;

lives-ok { $layout = Oyatul::Layout.from-json(path => 't/data/couchapp.layout') }, "create from file";

my $id;
ok $id = $layout.nodes-for-purpose('id').first, 'nodes-for-purpose';
isa-ok $id, Oyatul::File, "and it is a file";
does-ok $id, ::('IDRole'), "and it does the role we specified";
is $id.name, '_id', "and the one we expected";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
