use v6;

=begin pod

=head1 NAME 

Oyatul - Abstract representation of filesystem layout

=head1 SYNOPSIS

=begin code

=end code

=head1 DESCRIPTION

=end pod

use JSON::Tiny;

module Oyatul:ver<0.0.1> {

    role Node { ... }
    class File { ... }
    class Directory { ... }

    my role Parent {
        has Node @.children;
        method gather-children(IO::Path:D $root) {
            for $root.dir(test => /^<-[.]>/) -> $child {
                my $node;
                if $child.d {
                    $node = Directory.generate(root => $child, parent => self);
                }
                else {
                    $node = File.new(name => $child.basename, parent => self);
                }
                self.children.append: $node;
            }
        }

        method as-hash(Parent:D:) {
            my %h = type => self.what, children => [];
            %h<name> = self.name if self.can('name');
            for self.children -> $child {
                %h<children>.push: $child.as-hash;
            }
            %h;
        }
    }

    role Node {
        has Str  $.name;
        has Parent $.parent;
    }

    class File does Node {
        method as-hash(File:D:) {
            my %h = type => 'file', name => $!name;
            %h;
        }

    }

    class Directory does Node does Parent {

        has Str $.what = 'directory';

        proto method generate(|c) { * }

        multi method generate(IO::Path:D :$root!, Parent :$parent!) {
            my $dir = self.new(name => $root.basename, :$parent);
            $dir.gather-children($root);
            $dir;
        }

    }

    class Layout does Parent {
        has Str  $.root = '.';
        has Str  $.what = 'layout';

        proto method generate(|c) { * }

        multi method generate(Str :$root = '.') returns Layout {
            samewith(root => $root.IO);
        }

        multi method generate(IO::Path:D :$root!) {
            my $layout = self.new(root => $root.basename);
            $layout.gather-children($root);
            $layout;
        }

        method to-json() {
            to-json(self.as-hash);
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
