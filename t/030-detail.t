#!perl6

use v6;

use Test;


use Oyatul;

use lib $*PROGRAM.parent.child('lib').Str;

my $layout;

lives-ok { $layout = Oyatul::Layout.from-json(path => 't/data/couchapp.layout', root => 't/test-root');  }, "create from file";

my $id;
is $layout.root, 't/test-root', "got the root";
ok $id = $layout.nodes-for-purpose('id').first, 'nodes-for-purpose';
isa-ok $id, Oyatul::File, "and it is a file";
does-ok $id, ::('IDRole'), "and it does the role we specified";
is $id.name, '_id', "and the one we expected";

my $view-template;


lives-ok { $view-template = $layout.template-for-purpose('view') } , "template-for-purpose";
does-ok $view-template, Oyatul::Template, "and it is a template";


my $real-view;

lives-ok { $real-view = $view-template.make-real('by-name') }, "make-real";
nok $real-view ~~ Oyatul::Template, "and that isn't a Template";
is $real-view.path, "t/test-root/views/by-name", 'and that has the right path';


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
