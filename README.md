# Scatter.FM

Source code for https://scatterfm.markhansen.co.nz/, a scatterplot
visualization of Last.FM scrobbles. Date on x-axis, time on y-axis.

## Development

Start compiling TypeScript to JavaScript:

```shell
$ tsc --watch
```

Run a web server:

```
$ cd public/
$ python3 -m http.server
```

## Deploy

Happens automatically on merge
