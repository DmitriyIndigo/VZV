#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;

BEGIN { unshift @INC, "$FindBin::Bin/../lib" }
use Mojolicious::Commands;

Mojolicious::Commands->start_app('Vzv', 'daemon', '-l', 'http://localhost:8080');
