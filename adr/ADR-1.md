# ADR-1

## Context

There's a need for creating PNGs binaries without shelling out to an external runtime dependency.  It would also be convenient to produce PNGs from in-application data, without depending on loading & saving image files from the file system.

The only library that can currently do this is [yuce/png](https://github.com/yuce/png) which is an erlang library and doesn't provide native Elixir bindings.  The library is also incomplete and experiences bugs. The interface isn't suitable for in-application reading and writing and is more tailored for file reading and writing, like other libraries.

Writing a library which can do this is feasible due to comprehensive documentation in the domain.  [libpng.org](http://www.libpng.org/) has excellent documentation on the PNG image format which can be referenced to write a solution.

Native zlib compression interfaces are available via the erlang module `zlib` which can compress scanlines according to the PNG standards.

The following interface would be most convenient, as an example:

```elixir
config = %Config{
  width: 128,
  height: 128,
  color_mode: :grayscale,
  bit_depth: 8
}

image_with_white_corners = [
  [254, 0, 254],
  [0, 0, 0],
  [254, 0, 254]
]

# Outputs a binary
bytes = Sesopenko.PNG.encode(config, image_with_white_corners)
```

There isn't a functional need for predictive scanline compression methods at this point in time.  There's no need for interlaced PNGs.

## Proposed Solution

Build a PNG module which takes a config and an array of scanlines and produces an 8 bit grayscale image.

## Status

Accepted

## Consequences

List consequences experienced (positive and negative) after the decision was made.