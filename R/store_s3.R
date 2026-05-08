# https://zarr-specs.readthedocs.io/en/latest/v3/stores/s3/v1.0.html

# Helpers ------------------------------------------------------------------

s3_full_key <- function(store, key) {
  if (nzchar(store@prefix)) paste0(store@prefix, key) else key
}

s3_strip_prefix <- function(store, full_keys) {
  n <- nchar(store@prefix)
  if (n > 0L) substr(full_keys, n + 1L, nchar(full_keys)) else full_keys
}

s3_list_all <- function(client, bucket, prefix = "", delimiter = NULL) {
  args <- list(Bucket = bucket, Prefix = prefix)
  if (!is.null(delimiter)) args$Delimiter <- delimiter

  keys     <- character(0)
  prefixes <- character(0)

  repeat {
    resp <- do.call(client$list_objects_v2, args)

    if (length(resp$Contents) > 0) {
      keys <- c(keys, vapply(resp$Contents, `[[`, character(1), "Key"))
    }
    if (!is.null(delimiter) && length(resp$CommonPrefixes) > 0) {
      prefixes <- c(prefixes, vapply(resp$CommonPrefixes, `[[`, character(1), "Prefix"))
    }

    if (!isTRUE(resp$IsTruncated)) break
    args$ContinuationToken <- resp$NextContinuationToken
  }

  list(keys = keys, prefixes = prefixes)
}

# Class --------------------------------------------------------------------

#' S3 store
#'
#' A Zarr V3 store backed by an AWS S3 bucket. Keys map to S3 object keys
#' under an optional `prefix`. The store uses \pkg{paws.storage} for all S3
#' operations; credentials and region are resolved via the standard AWS
#' credential chain (environment variables, `~/.aws/credentials`, instance
#' metadata, etc.).
#'
#' @param bucket Name of the S3 bucket.
#' @param prefix Optional key prefix (e.g. `"my-array/"`) applied to all
#'   keys stored in this store. Must end with `"/"` if non-empty.
#' @param ... Additional arguments passed to [paws.storage::s3()], such as
#'   `region`, `endpoint`, or `credentials`.
#' @returns An `S3Store` object.
#'
#' @export
S3Store <- new_class(
  "S3Store",
  parent = Store,
  properties = list(
    bucket  = class_character,
    prefix  = class_character,
    .client = class_any
  ),
  constructor = function(bucket, prefix = "", ...) {
    client <- paws.storage::s3(...)
    new_object(S7_object(), bucket = bucket, prefix = prefix, .client = client)
  }
)

# Read operations ----------------------------------------------------------

method(store_get, S3Store) <- function(store, key) {
  full_key <- s3_full_key(store, key)
  resp <- tryCatch(
    store@.client$get_object(Bucket = store@bucket, Key = full_key),
    error = function(e) NULL
  )
  if (is.null(resp)) return(NULL)
  resp$Body
}

# Write operations ---------------------------------------------------------

method(store_set, S3Store) <- function(store, key, value) {
  full_key <- s3_full_key(store, key)
  store@.client$put_object(Bucket = store@bucket, Key = full_key, Body = value)
  invisible(NULL)
}

# List operations ----------------------------------------------------------

method(store_list, S3Store) <- function(store) {
  result <- s3_list_all(store@.client, store@bucket, prefix = store@prefix)
  s3_strip_prefix(store, result$keys)
}

method(store_list_prefix, S3Store) <- function(store, prefix) {
  full_prefix <- s3_full_key(store, prefix)
  result <- s3_list_all(store@.client, store@bucket, prefix = full_prefix)
  s3_strip_prefix(store, result$keys)
}

method(store_list_dir, S3Store) <- function(store, prefix) {
  full_prefix <- s3_full_key(store, prefix)
  result <- s3_list_all(store@.client, store@bucket, prefix = full_prefix, delimiter = "/")
  list(
    keys     = s3_strip_prefix(store, result$keys),
    prefixes = s3_strip_prefix(store, result$prefixes)
  )
}
