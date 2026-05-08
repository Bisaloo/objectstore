test_that("`store_list()` FilesystemStore", {
  tmp <- withr::local_tempfile()
  store <- FilesystemStore(tmp)
  
  expect_length(store_list(store), 0)

  x <- as.raw(1:10)
  store_set(store, "foo", x)
  expect_equal(store_list(store), file.path(tmp, "foo"), ignore_attr = TRUE)
})

test_that("`store_list()` S3Store", {
  skip_if_offline("s3.embl.de")

  store <- S3Store(
    bucket = "rarr-testing", 
    prefix = "bzip2.zarr/", 
    endpoint = "https://s3.embl.de/", 
    credentials = list(
      creds = list(
        access_key_id     = "bYUBYVg1AsEreuDgtg5K",
        secret_access_key = "r8FrLXc9dseD6V1P3htsu7ZBzP7Gszsd3sM1G4KX"
      )
    ),
    region = "auto"
  )

  expect_equal(store_list(store), c(".zarray","0.0", "1.0"), ignore_attr = TRUE)
})

test_that("`store_list_prefix()` FilesystemStore", {
  tmp <- withr::local_tempfile()
  store <- FilesystemStore(tmp)
  
  expect_length(store_list_prefix(store, "foo"), 0)

  x <- as.raw(1:10)
  store_set(store, "foo/bar", x)
  store_set(store, "foo/baz/eds", x)
  store_set(store, "qux/quux", x)
  
  expect_equal(store_list_prefix(store, "foo"), file.path(tmp, c("foo/bar", "foo/baz/eds")), ignore_attr = TRUE)
})

test_that("`store_list_prefix()` S3Store", {
  skip_if_offline("s3.embl.de")

  store <- S3Store(
    bucket = "rarr-testing", 
    prefix = "bzip2.zarr/", 
    endpoint = "https://s3.embl.de/", 
    credentials = list(
      creds = list(
        access_key_id     = "bYUBYVg1AsEreuDgtg5K",
        secret_access_key = "r8FrLXc9dseD6V1P3htsu7ZBzP7Gszsd3sM1G4KX"
      )
    ),
    region = "auto"
  )

  expect_equal(store_list_prefix(store, "0"), "0.0", ignore_attr = TRUE)
})

test_that("`store_list_dir()` FilesystemStore", {
  tmp <- withr::local_tempfile()
  store <- FilesystemStore(tmp)
  
  x <- as.raw(1:10)
  store_set(store, "foo/bar", x)
  store_set(store, "foo/baz/eds", x)
  store_set(store, "qux/quux", x)
  
  result <- store_list_dir(store, "foo")
  expect_equal(result$keys, file.path(tmp, "foo/bar"), ignore_attr = TRUE)
  expect_equal(result$prefixes, file.path(tmp, "foo/baz/"), ignore_attr = TRUE)
})

test_that("`store_list_dir()` S3Store", {
  skip_if_offline("s3.embl.de")

  store <- S3Store(
    bucket = "rarr-testing", 
    prefix = "bzip2.zarr/", 
    endpoint = "https://s3.embl.de/", 
    credentials = list(
      creds = list(
        access_key_id     = "bYUBYVg1AsEreuDgtg5K",
        secret_access_key = "r8FrLXc9dseD6V1P3htsu7ZBzP7Gszsd3sM1G4KX"
      )
    ),
    region = "auto"
  )

  result <- store_list_dir(store, "")
  expect_equal(result$keys, c(".zarray","0.0", "1.0"), ignore_attr = TRUE)
  expect_equal(result$prefixes, character(0), ignore_attr = TRUE)
})