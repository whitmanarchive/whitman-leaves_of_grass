# Whitman Archive Leaves of Grass Data Repo

This is a data repository designed to work with the CDRH's [Datura Ruby gem](https://github.com/CDRH/datura).

It contains TEI-XML files for seven Leaves of Grass editions. For TEI-XML and scripts specific to the 1855 edition used for the Variorum, please see the [Variorum data repository](https://github.com/whitmanarchive/whitman-LG_1855_variorum).

## Scripts

This repo shares its Ruby gem dependencies with all other Whitman data
repos via the
[Gemfile](https://github.com/whitmanarchive/whitman-scripts/blob/main/Gemfile)
in the [whitman-scripts
repo](https://github.com/whitmanarchive/whitman-scripts)

This repo also has works-related documents which require `post`-ing
with `threads: 1` in `config/public.yml` or `config/private.yml` to not
break writing to `../whitman-scripts/source/json/works_and_items.json`

If you do not set threads to 1, then there will be a message `set threads to 1 in private.yml to modify works_and_items file`. See [works ingest documentation](https://github.com/whitmanarchive/whitman-scripts/blob/dev/docs/work-ingest.md).

This repo has sub-documents so HTML generation also requires `threads: 1`

For information about populating the CDRH API or generating HTML views, see [Datura's documentation](https://github.com/CDRH/datura).

### Poem identifier

Poems are encoded throughout the editions as `<lg type="poem">` and `<lg type="cluster">`. Most of these poems also carry a unique identifier.

You may run a command to check if there are poems missing an identifier and if any poems have a duplicate identifier.

This command assumes you have Ruby installed. Check `.ruby-version` to find the preferred version.

```bash
bundle install

./scripts/poem_identifier.rb
```
