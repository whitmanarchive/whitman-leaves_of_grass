# Whitman Archive Leaves of Grass Data Repo

This is a data repository designed to work with the CDRH's [Datura Ruby gem](https://github.com/CDRH/datura).

It contains TEI-XML files for seven Leaves of Grass editions. For TEI-XML and scripts specific to the 1855 edition used for the Variorum, please see the [Variorum data repository](https://github.com/whitmanarchive/whitman-LG_1855_variorum).

## Scripts

For information about populating the CDRH API or generating HTML views, see [Datura's documentation](https://github.com/CDRH/datura).

### Poem identifier

Poems are encoded throughout the editions as `<lg type="poem">` and `<lg type="cluster">`. Most of these poems also carry a unique identifier.

You may run a command to check if there are poems missing an identifier and if any poems have a duplicate identifier.

This command assumes you have Ruby installed. Check `.ruby-version` to find the preferred version.

```bash
bundle install

./scripts/poem_identifier.rb
```
