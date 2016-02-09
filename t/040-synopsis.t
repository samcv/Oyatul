use v6.c;

use Oyatul;
use Test;

lives-ok {
my $description = q:to/LAY/;
{
   "type" : "layout",
   "children" : [
      {
         "name" : "t",
         "purpose" : "tests",
         "type" : "directory",
         "children" : [
            {
               "type" : "file",
               "purpose" : "test",
               "template" : true
            }
         ]
      },
      {
         "type" : "directory",
         "purpose" : "lib",
         "name" : "lib",
         "children" : []
      }
   ]
}
LAY

# the :real adverb causes instance nodes to be inserted
# for any templates if they exist.
my $layout = Oyatul::Layout.from-json($description, root => $*CWD.Str, :real);

# get the directory that stands in for 'lib'
my $lib = $layout.nodes-for-purpose('lib').first.path;

# get all the instances for 'test' excluding the template
for $layout.nodes-for-purpose('test', :real) -> $test {
	run($*EXECUTABLE, '-I', $lib, $test.path, :out, :err);
}
}, "the synopsis runs ok";

done-testing;
