# hanging side comments
if ($seen == 1)
{    # We're the first word so far to have
     # this abbreviation.
    $hashref->{$abbrev} = $word;
}
elsif ($seen == 2)
{    # We're the second word to have this
     # abbreviation, so we can't use it.
    delete $hashref->{$abbrev};
}
else
{    # We're the third word to have this
     # abbreviation, so skip to the next word.
    next WORD;
}
