# ADR 0001: User media storage

## Decision

Store uploaded binary files in an S3-compatible object storage. Use Yandex
Object Storage for the first production environment and keep the application
integration compatible with the AWS S3 API.

PostgreSQL stores media metadata and object keys, not file contents or
long-lived signed URLs.

## Upload flow

1. An authenticated client asks the backend to create an upload.
2. The backend validates media type and ownership, creates a pending media
   record, and returns a short-lived pre-signed `PUT` URL.
3. The client uploads directly to object storage.
4. The client confirms the upload with the backend.
5. A worker validates the object, extracts dimensions, creates optimized
   variants, strips unsafe metadata, and marks the media as ready.

## Storage policy

- Keep original uploads private.
- Never expose bucket listing publicly.
- Serve approved, optimized variants through a CDN or short-lived signed URL.
- Use immutable object keys containing generated UUIDs; never use original file
  names as keys.
- Keep separate prefixes for originals and generated variants.
- Configure lifecycle deletion for abandoned multipart and pending uploads.
- Validate MIME type, magic bytes, dimensions, file size, and ownership.
- Do not store cloud access keys in Flutter or in the repository.

Suggested keys:

```text
originals/{ownerId}/{mediaId}
variants/{ownerId}/{mediaId}/avatar-256.webp
variants/{ownerId}/{mediaId}/card-640.webp
variants/{ownerId}/{mediaId}/portfolio-1280.webp
```

## Planned database metadata

The media module will own a `media_assets` table with the owner, purpose,
object key, content type, size, checksum, dimensions, processing status, and
timestamps. Domain tables will reference `media_assets.id`. Portfolio ordering
and captions will live in a separate relation.

## Fallback

The client renders one design-system fallback avatar whenever a profile has no
ready avatar or a remote image cannot be loaded.
