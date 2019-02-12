# Bigtable

Elixir client library for Google Bigtable.

[![Hex.pm](https://img.shields.io/hexpm/v/bigtable.svg)](https://hex.pm/packages/bigtable)
[![Build Status](https://travis-ci.org/bzzt/bigtable.svg?branch=master)](https://travis-ci.org/bzzt/bigtable)
[![codecov](https://codecov.io/gh/bzzt/bigtable/branch/master/graph/badge.svg)](https://codecov.io/gh/bzzt/bigtable)
[![codebeat badge](https://codebeat.co/badges/6203650d-db88-4c48-9173-948cc3404145)](https://codebeat.co/projects/github-com-bzzt-bigtable-master)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://spacemacs.org)

## Documentation

Documentation available at https://hexdocs.pm/bigtable/

## Installation

The package can be installed as:

```elixir
def deps do
 [{:bigtable, "~> 0.5.0"}]
end
```

## Warning!

**WORK IN PROGRESS. DOCUMENTATION MAY BE INCORRECT. DO NOT USE IN PRODUCTION.**

## Feature List

### Operations:

- [x] Check And Mutate Row
- [x] Mutate Row
- [x] Mutate Rows
- [x] Read Modify Write Row
- [x] Read Rows
- [x] Sample Row Keys

### Mutations:

- [x] Delete From Column
- [x] Delete From Family
- [x] Delete From Row
- [x] Set Cell

### Row Sets:

- [x] Row Keys
- [x] Row Ranges

### Row Filters:

- [x] Block All
- [x] Cells Per Column Limit
- [x] Chain
- [x] Column Qualifier Regex
- [x] Column Range
- [x] Family Name Regex
- [x] Pass All
- [x] Row Key Regex
- [x] Timestamp Range
- [x] Value Regex
- [ ] Apply Label Transformer
- [ ] Cells Per Row Limit
- [ ] Cells Per Row Offset
- [ ] Condition
- [ ] Interleave
- [ ] Row Sample
- [ ] Strip Value Transfformer
- [ ] Value Range
