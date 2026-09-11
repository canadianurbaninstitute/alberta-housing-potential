# Alberta Housing Potential

### Local testing

The map (`index.html`) uses PMTiles, which fetches tile data via HTTP byte-range requests — this doesn't work when opening `index.html` directly (`file://`), so serve it locally instead:

```
npx http-server -p 8080 -c-1
```

Then open http://localhost:8080 in a browser. Stop the server with Ctrl+C.

### Data Sources

Statistics Canada. Table 17-10-0155-01 Population estimates, July 1, by census subdivision, 2021 boundaries

Statistics Canada. Table 17-10-0162-01 Projected population for census divisions and census subdivisions, 2021 boundaries, by projection scenario, age and gender, as of July 1
