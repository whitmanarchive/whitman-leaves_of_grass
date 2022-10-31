# Whitman Archive Leaves of Grass Data Repo

This is a data repository designed to work with the CDRH's [Datura Ruby gem](https://github.com/CDRH/datura).

It contains TEI-XML files for seven Leaves of Grass editions. For TEI-XML and scripts specific to the 1855 edition used for the Variorum, please see the [Variorum data repository](https://github.com/whitmanarchive/whitman-LG_1855_variorum).

## Scripts

For information about populating the CDRH API or generating HTML views, see [Datura's documentation](https://github.com/CDRH/datura).

### Poem identifier script

Poems are encoded throughout the editions as `<lg type="poem">` and `<lg type="cluster">`. Most of these poems also carry a unique identifier.

You may run a command to check if there are poems missing an identifier and if any poems have a duplicate identifier.

This command assumes you have Ruby installed. Check `.ruby-version` to find the preferred version.

```bash
bundle install

./scripts/poem_identifier.rb
```

### Poem id assigning script

CAUTION: This script is destructive in the wrong hands, and possibly even in the right ones. It was written very hastily to
squish some identifiers into poems that were missing it,
and was not written with the idea in mind that it would be run again!

```bash
bundle install
./scripts/poem_id_assigner.rb
```

The script will give you a big warning (type "y" to continue)
and then will ask for an identifier to START with. Aka: whatever
you got as output from the poem identifier script, add one
