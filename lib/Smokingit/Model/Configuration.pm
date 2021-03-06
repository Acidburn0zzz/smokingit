use strict;
use warnings;

package Smokingit::Model::Configuration;
use Jifty::DBI::Schema;

use Smokingit::Record schema {
    column project_id =>
        references Smokingit::Model::Project;

    column name =>
        is mandatory,
        label is "Name",
        type is "text";

    column configure_cmd =>
        type is 'text',
        label is "Configuration commands",
        default is 'perl Makefile.PL && make',
        render_as 'Textarea';

    column env =>
        type is 'text',
        label is "Environment variables",
        render_as 'Textarea';

    column test_glob =>
        type is 'text',
        label is 'Glob of test files',
        default is "t/*.t";

    column parallel =>
        is boolean,
        label is 'Parallel testing?',
        default is 't';

    column auto =>
        is boolean,
        label is 'Automatically test?',
        default is 't',
        since '0.0.9';
};

sub create {
    my $self = shift;
    my ($ok, $msg) = $self->SUPER::create(@_);
    return ($ok, $msg) unless $ok;

    Jifty->rpc->call(
        name => "plan_tests",
        args => $self->project->name,
    );

    return ($ok, $msg);
}

sub current_user_can {
    my $self  = shift;
    my $right = shift;
    my %args  = (@_);

    return 1 if $right eq 'create' and $self->current_user->id;
    return 1 if $right eq 'read';
    return 1 if $right eq 'update' and $self->current_user->id;
    return 1 if $right eq 'delete' and $self->current_user->id;

    return $self->SUPER::current_user_can($right => %args);
}

1;

