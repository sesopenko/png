# Sesopenko.PNG

Runtime PNG compression library.  Creates 8 bit grayscale PNG binaries from scanline lists.

## Example Usage

```elixir
config = Sesopenko.PNG.Config.get(3, 3)

image_with_white_corners = [
  [254, 0, 254],
  [0, 0, 0],
  [254, 0, 254]
]

binary_data = Sesopenko.PNG.create(config, image_with_white_corners)

```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sesopenko` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sesopenko_png, "~> 1.0.2"}
  ]
end
```

## Capabilities

* 8 bit grayscale

## References:

* [Extarcting PNG Chunks with Go](https://parsiya.net/blog/2018-02-25-extracting-png-chunks-with-go/), Hackerman's hacking tools
* [PNG Specifications](http://www.libpng.org/pub/png/spec/1.2/PNG-Contents.html), libpng.org
* [Portable Network Graphics](https://en.wikipedia.org/wiki/Portable_Network_Graphics#%22Chunks%22_within_the_file), Wikipedia
* [ACII Table and Description](http://www.asciitable.com/), Asciitable.com

## License

This is licensed GNU GPL v3 and is described in LICENSE.txt. 