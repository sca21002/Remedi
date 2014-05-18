package Remedi::Cmd;

use Moose;

# ABSTRACT: Basic command class for CLI

extends qw(MooseX::App::Cmd);

__PACKAGE__->meta->make_immutable;
1;
