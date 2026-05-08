test_that("`store_set()`/`store_get()` FilesystemStore", {
  tmp <- withr::local_tempfile()
  store <- FilesystemStore(tmp)
  
  expect_null(store_get(store, "foo"))

  x <- as.raw(1:10)
  store_set(store, "foo", x)
  expect_identical(store_get(store, "foo"), x)
})

test_that("`store_get()` S3Store", {
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

  expect_null(store_get(store, "foo"))

  expect_type(store_get(store, "0.0"), "raw")
})
