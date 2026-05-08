# https://zarr-specs.readthedocs.io/en/latest/v3/stores/filesystem/index.html

# Class --------------------------------------------------------------------

#' Filesystem store
#'
#' A Zarr V3 store backed by a local filesystem directory. Keys map directly
#' to file paths relative to `root`. Intermediate directories are created
#' automatically on write.
#'
#' @param root Path to the root directory of the store. Will be created if it
#'   does not exist.
#' @returns A `FilesystemStore` object.
#'
#' @export
FilesystemStore <- new_class(
  "FilesystemStore",
  parent = Store,
  properties = list(
    root = class_character
  ),
  constructor = function(root) {
    root <- fs::path_norm(root)
    fs::dir_create(root, recurse = TRUE)
    new_object(S7_object(), root = root)
  }
)

# Read operations ----------------------------------------------------------
method(store_get, FilesystemStore) <- function(store, key) {
  path <- fs::path(store@root, key)
  if (!fs::file_exists(path)) {
    return(NULL)
  }
  readBin(path, what = "raw", n = fs::file_info(path)$size)
}

# Write operations ---------------------------------------------------------
method(store_set, FilesystemStore) <- function(store, key, value) {
  path <- fs::path(store@root, key)
  dir  <- fs::path_dir(path)
  fs::dir_create(dir, recurse = TRUE)
  writeBin(value, path)
  invisible(NULL)
}

# List operations ----------------------------------------------------------
method(store_list, FilesystemStore) <- function(store) {
  fs::dir_ls(store@root, recurse = TRUE, all = TRUE, type = "file")
}

method(store_list_prefix, FilesystemStore) <- function(store, prefix) {
  all_files <- store_list(store)
  
  to_keep <- all_files |>
     fs::path_rel(start = store@root) |>
     startsWith(prefix)
  
  all_files[to_keep]
}

method(store_list_dir, FilesystemStore) <- function(store, prefix) {
  all_elements <- fs::dir_ls(store@root, recurse = 1, all = TRUE)
  rel_elements <- fs::path_rel(all_elements, start = store@root)

  to_keep <- startsWith(rel_elements, prefix)

  keys     <- all_elements[to_keep & fs::is_file(all_elements)]
  prefixes <- all_elements[to_keep & fs::is_dir(all_elements)] |> 
    setdiff(fs::path(store@root, prefix))

  return(
    list(
      keys     = keys,
      prefixes = paste0(prefixes, "/")
    )
  )
}