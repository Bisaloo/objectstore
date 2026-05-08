# https://zarr-specs.readthedocs.io/en/latest/v3/core/index.html#abstract-store-interface

# Virtual base class -------------------------------------------------------

#' Abstract Zarr V3 store
#'
#' Virtual base class for all store backends. Subclass this to implement a
#' concrete store (e.g. filesystem, in-memory, S3).
#'
#' @export
Store <- new_class("Store", abstract = TRUE)


# Read operations ----------------------------------------------------------

#' Retrieve the value associated with a given key
#'
#' @param store A `ZarrStore` object.
#' @param key A string key.
#' @returns The value associated with `key`, or `NULL` if the key is absent.
#' @export
store_get <- new_generic("store_get", "store")

# Write operations ---------------------------------------------------------

#' Store a (key, value) pair
#'
#' @param store A `ZarrStore` object.
#' @param key A string key.
#' @param value The value to store.
#' @returns `NULL`, invisibly.
#' @export
store_set <- new_generic("store_set", "store")

# Erase operations ---------------------------------------------------------

#' Erase a single key/value pair from the store
#'
#' @param store A `ZarrStore` object.
#' @param key A string key to erase.
#' @returns `NULL`, invisibly.
#' @note Some stores (e.g. Zip archives) do not support deletion.
#' @export
store_erase <- new_generic("store_erase", "store")

#' Erase a set of key/value pairs from the store
#'
#' @param store A `ZarrStore` object.
#' @param keys A character vector of keys to erase.
#' @returns `NULL`, invisibly.
#' @note Some stores (e.g. Zip archives) do not support deletion.
#' @export
store_erase_values <- new_generic("store_erase_values", "store")

#' Erase all keys with a given prefix
#'
#' @param store A `ZarrStore` object.
#' @param prefix A string prefix. All keys beginning with this prefix are
#'   erased.
#' @returns `NULL`, invisibly.
#' @note Some stores (e.g. Zip archives) do not support deletion.
#' @export
store_erase_prefix <- new_generic("store_erase_prefix", "store")

# List operations ----------------------------------------------------------

#' Retrieve all keys in the store
#'
#' @param store A `ZarrStore` object.
#' @returns A character vector of all keys.
#' @export
store_list <- new_generic("store_list", "store")

#' Retrieve all keys with a given prefix
#'
#' @param store A `ZarrStore` object.
#' @param prefix A string prefix ending with `/`. The behaviour is undefined if
#'   `prefix` does not end with `/`.
#' @returns A character vector of keys that start with `prefix`. For example,
#'   if the store contains `"a/b"`, `"a/c/d"`, and `"e/f/g"`, then
#'   `store_list_prefix(store, "a/")` returns `c("a/b", "a/c/d")`.
#' @export
store_list_prefix <- new_generic("store_list_prefix", "store")

#' Retrieve keys and sub-prefixes under a given prefix (single depth)
#'
#' Returns only the keys and prefixes directly under `prefix`, i.e. those that
#' do not contain an additional `/` after `prefix`.
#'
#' @param store A `ZarrStore` object.
#' @param prefix A string prefix ending with `/`.
#' @returns A named list with two character vectors:
#'   - `keys`: keys that start with `prefix` and contain no further `/`.
#'   - `prefixes`: sub-prefixes (each ending with `/`) that appear under
#'     `prefix`.
#'
#'   For example, if the store contains `"a/b"`, `"a/c"`, `"a/d/e"`,
#'   `"a/f/g"`, then `store_list_dir(store, "a/")` returns
#'   `list(keys = c("a/b", "a/c"), prefixes = c("a/d/", "a/f/"))`.
#' @export
store_list_dir <- new_generic("store_list_dir", "store")
