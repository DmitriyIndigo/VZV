package Vzv;

use strict;
use Data::Dumper;

use Mojo::Base 'Mojolicious';
use Mojo::File 'path';
use Mojo::Home;
use Mojolicious::Plugin::Database;

sub startup {
    my $self = shift;
    
    # Switch to installable home directory
    $self->home(Mojo::Home->new(path(__FILE__)->dirname() . '/..'));
    
    # Switch to installable "public" directory
    $self->static->paths->[0] = $self->home->child('public');
    
    # Switch to installable "templates" directory
    $self->renderer->paths->[0] = $self->home->child('templates');
    
    $self->plugin('database', {
        databases => {
            'db' => {
                dsn      => "DBI:mysql:host=localhost;database=VZV",
                username => 'root',
                password => 'root', 
                options  => { RaiseError => 1,   PrintError => 1 , mysql_enable_utf8 => 1 , mysql_auto_reconnect => 1},
            }
        }
    });
    
    my $routes = $self->routes;
    
    $routes->any(['GET', 'POST'] => '/')->to('main#root');
}

1;