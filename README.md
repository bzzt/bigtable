# Bigtable

Elixir client library for Google Bigtable.

[![Hex.pm](https://img.shields.io/hexpm/v/bigtable.svg)](https://hex.pm/packages/bigtable)
[![Build Status](https://travis-ci.org/bzzt/bigtable.svg?branch=master)](https://travis-ci.org/bzzt/bigtable)
[![codecov](https://codecov.io/gh/bzzt/bigtable/branch/master/graph/badge.svg)](https://codecov.io/gh/bzzt/bigtable)
[![codebeat badge](https://codebeat.co/badges/6203650d-db88-4c48-9173-948cc3404145)](https://codebeat.co/projects/github-com-bzzt-bigtable-master)

## Documentation

Documentation available at https://hexdocs.pm/bigtable/

## Installation

The package can be installed as:

```elixir
def deps do
 [{:bigtable, "~> 0.1.0"}]
end
```

## Warning!

**WORK IN PROGRESS. DOCUMENTATION MAY BE INCORRECT. DO NOT USE IN PRODUCTION.**

## Feature List

### Operations:

- [x] Read Rows
- [x] Mutate Row
- [x] Mutate Rows
- [ ] Check And Mutate Row
- [ ] Read Modify Write Row
- [ ] Sample Row Keys

### Mutations:

- [x] Set Cell
- [x] Delete From Column
- [x] Delete From Family
- [x] Delete From Row

### Row Sets:

- [x] Row Keys
- [x] Row Ranges

### Row Filters:

- [x] Chain
- [x] Cells Per Column Limit
- [x] Row Key Regex
- [x] Value Regex
- [x] Family Name Regex
- [x] Column Qualifier Regex
- [x] Column Range
- [x] Timestamp Range
- [ ] Condition
- [ ] Row Sample
- [ ] Value Range
- [ ] Cells Per Row Offset
- [ ] Cells Per Row Limit
- [ ] Strip Value Transfformer
- [ ] Apply Label Transformer

### Read Modify Write Rule:

- [ ] Family Name
- [ ] Column Qualifier
- [ ] Append Value
- [ ] Increment Amount
