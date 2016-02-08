#!perl6

use v6;

use Test;

use Oyatul;

my $layout;

lives-ok { $layout = Oyatul::Layout.generate }, "generate";

isa-ok $layout, Oyatul::Layout, "and we got the right sort of thing";

my %hash;

lives-ok { %hash = $layout.to-hash }, "get the layout as a hash";

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

my $json;

lives-ok { $json = $layout.to-json() }, "to-json";

my $layout2;

lives-ok { $layout2 = Oyatul::Layout.from-json($json); }, "from-json"; 
is-deeply $layout2.to-hash, %hash, "and it's the same as the one we made earlier";

for $layout.all-children -> $child {
    ok $child.IO.e, "path got by all-children '{ $child.path }' exists";
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
