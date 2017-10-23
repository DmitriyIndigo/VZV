package Vzv::Controller::Main;

use Mojo::Base 'Mojolicious::Controller';

my $LIMIT = 100;

sub root {
    my $self = shift;

    my $error;
    my $pagination = [];
    my $all_data   = [];
    my $phone      = $self->req->param('phone');
    my $page       = $self->req->param('page') // 1;

    $error = sprintf('Invalid format: %s', $page) unless $page =~ m/^\d+\z/;

    my $q = "select %s from vzv";

    if (defined($phone) && $phone ne '') {
        $error = sprintf('Phone invalid format: %s', $phone)
          unless $phone =~ m/^8\d{10}\z/;

        $q .= ' where phone = ?';
    }

    my $query = sprintf($q, 'count(id) AS count_id');
    my $sth = $self->db->prepare($query);
    $sth->execute($phone ? $phone : ());
    my $count = $sth->fetchall_arrayref({})->[0]->{'count_id'} || 1;

    my $offset    = ($page - 1) * $LIMIT;
    my $pages     = $count / $LIMIT;
    my $max_pages = int($pages);
    $max_pages += 1 if $pages != $max_pages;

    $pagination = pagination($page, $max_pages);

    unless ($error) {
        $query = sprintf($q, 'name, phone, created');

        $query .= " limit $offset, $LIMIT";

        my $sth = $self->db->prepare($query);
        $sth->execute($phone ? $phone : ());
        $all_data = $sth->fetchall_arrayref({});
    }

    return $self->render(
        template   => 'main/main',
        format     => 'html',
        handler    => 'ep',
        phone      => $phone,
        error      => $error,
        all_data   => $all_data,
        pagination => $pagination,
    );
}

sub pagination {
    my ($page, $max_pages) = @_;
    my $flack_plus  = 1;
    my $flack_minus = 1;
    my $i           = 1;

    my @pagination = ();
    push(@pagination, {page => $page, class => 'active'});

    while ($flack_plus || $flack_minus) {
        if ($flack_plus) {
            my $page_plus = $page + $i;

            if ($page_plus > $max_pages) {
                $flack_plus = 0;
            } else {
                push(@pagination, {page => $page_plus, class => 'waves-effect'});
            }
        }

        if ($flack_minus) {
            my $page_minus = $page - $i;

            if ($page_minus < 1) {
                $flack_minus = 0;
            } else {
                unshift(@pagination, {page => $page_minus, class => 'waves-effect'});
            }
        }

        if ($i < 4) {
            $i++;
        } elsif ($i == 5) {
            $i = 100;
        } else {
            $i *= 10;
        }
    }

    unshift(@pagination, {page => 1, class => 'waves-effect'}) if $pagination[0]->{page} != 1;
    push(@pagination, {page => $max_pages, class => 'waves-effect'}) if $pagination[-1]->{page} != $max_pages;

    return \@pagination;
}

1;
