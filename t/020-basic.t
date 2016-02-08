#!perl6

use v6;

use Test;

use Oyatul;

my $layout;

lives-ok { $layout = Oyatul::Layout.generate }, "generate";

isa-ok $layout, Oyatul::Layout, "and we got the right sort of thing";

my %hash;

lives-ok { %hash = $layout.as-hash }, "get the layout as a hash";

for $layout.children -> $child {
    does-ok $child, Oyatul::Node, "and the child '{ $child.name }' is a node";
    my @children = %hash<children>.grep({ $_<name> eq $child.name });
    ok so @children, "and it's in the hash";
    if $child ~~ Oyatul::Directory {
        for $child.children -> $child {
            ok @children[0]<children>.grep({ $_<name> eq $child.name}), "and its child '{ $child.name }' too";
        }
    }
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
