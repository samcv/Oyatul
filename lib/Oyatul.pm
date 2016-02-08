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

        method to-hash(Parent:D:) {
            my %h = type => self.what, children => [];
            %h<name> = self.name if self.can('name');
            for self.children -> $child {
                %h<children>.push: $child.to-hash;
            }
            %h;
        }

        method children-from-hash(Parent:D: %h) {
            for %h<children>.list -> $child {
                my $child-node = do given $child<type> {
                    when 'directory' {
                        Directory.from-hash(parent => self, $child);
                    }
                    when 'file' {
                        File.from-hash(parent => self, $child);
                    }
                    default {
                        die 'DAFUQ!';
                    }
                }
                self.children.append: $child-node;
            }
        }

        method all-children() {
            gather {
                for self.children.list -> $child {
                    take $child;
                    if $child ~~ Parent {
                        for $child.all-children -> $child {
                            take $child;
                        }
                    }

                }
            }
        }

        method delete() returns Bool {
            my @res;
            for self.children -> $child {
                @res.append: $child.delete;
            }
            @res.append: self.IO.rmdir;
            so all(@res);
        }
    }

    role Node {
        has Str  $.name;
        has Parent $.parent;

        method path-parts() {
            my @parts = $!name;
            if $!parent.defined {
                @parts.prepend: $!parent.path-parts;
            }
            @parts;
        }

        method path() returns Str {
            $*SPEC.catdir(self.path-parts);
        }

        method IO() returns IO::Path {
            self.path.IO;
        }

        method create() returns Bool {
            ...
        }

        method delete() returns Bool {
            ...
        }
    }

    class File does Node {
        method to-hash(File:D:) {
            my %h = type => 'file', name => $!name;
            %h;
        }

        method from-hash(%h, Parent:D :$parent) {
            self.new(:$parent,|%h);
        }

        method create() returns Bool {
            my $fh = self.IO.open(:w);
            $fh.close;
        }
        method delete() returns Bool {
            self.IO.unlink;
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

        method from-hash(Directory:U: %h, Parent:D :$parent) {
            my $dir = self.new(name => %h<name>, :$parent);
            $dir.children-from-hash(%h);
            $dir;
        }

        method create() returns Bool {
            my @res = self.IO.mkdir();
            for self.children -> $child {
                @res.append: $child.create;
            }
            so all(@res);
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

        method from-hash(%h, :$root) {
            my $layout = self.new(:$root);
            $layout.children-from-hash(%h);
            $layout;
        }

        method to-json() {
            to-json(self.to-hash);
        }

        method from-json(Layout:U: Str $json, Str() :$root) returns Layout {
            self.from-hash(from-json($json), :$root);
        }

        method path-parts() {
            $!root;
        }

        method create(Str :$root) returns Bool {
            $!root = $root.Str if $root.defined;

            if !$!root.IO.e {
                $!root.IO.mkdir;
            }
            my Bool @res;
            for self.children -> $child {
                @res.append: $child.create;
            }
            so all(@res);
        }
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
