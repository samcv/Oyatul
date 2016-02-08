use v6;

=begin pod

=head1 NAME 

Oyatul - Abstract representation of filesystem layout

=head1 SYNOPSIS

=begin code

=end code

=head1 DESCRIPTION

=end pod

module Oyatul {
    class Node {
        has Str  $.name;
        has Node $.parent;
    }

    class Directory is Node {
        has Node @.children;

    }
    class File is Node {

    }

    class Layout {
        has Node @.children;
        has Str  @.root = '.';
    }
}
# vim: expandtab shiftwidth=4 ft=perl6
