// these are colors that are pretty easy to tell apart in the graph.
// we don't want colors that are hard to distinguish, like purple vs violet
const COLORS = [ "red", "green", "blue", "purple",
           "brown", "orange", "cyan", "magenta" ];

let FlotScrobbleGraphView = Backbone.View.extend({
  render() {
    if (scrobbleCollection.size() === 0) { return; }
    graphViewModel.set({isDrawing: true});
  
    // The plotting locks up the DOM, so give it a chance to update
    // with a status message before launching the expensive plotting.
    return _.defer(function() {
      legendModel.compute_artist_colors(scrobbleCollection);
      let re = appModel.filterRegex();

      let filtered_scrobbles = scrobbleCollection.filter(s => re.exec(s.track()) || re.exec(s.artist()) || re.exec(s.album()));

      let flot_series = construct_flot_series(filtered_scrobbles);

      let minTime = scrobbleCollection.min(scrobble => scrobble.date()).date();
      let maxTime = scrobbleCollection.max(scrobble => scrobble.date()).date();

      plot_flot_series(flot_series, minTime, maxTime);
      return graphViewModel.set({isDrawn: true, isDrawing: false});
    });
  }
});

var construct_flot_series = function(scrobbles) {
  window.track_indices = {
    // Here's an example:
    //"snow patrol#eyes open": {
      //series_index: 1
      //datapoint_index: 0
    //}
  };

  let series = [];

  for (let scrobble of Array.from(scrobbles)) {
    let date = scrobble.date().getTime();
    let time = scrobble.date().getHours() + (scrobble.date().getMinutes() / 60);
    series.push({
      color: legendModel.get("artistColors")[scrobble.artist()].color,
      data: [[date, time]],
      scrobble
    });
    if ((track_indices[scrobble.artist() + "#" + scrobble.track()] == null)) {
      track_indices[scrobble.artist() + "#" + scrobble.track()] = [];
    }
    track_indices[scrobble.artist() + "#" + scrobble.track()].push({
      series_index: series.length - 1,
      datapoint_index: 0
    });
  }
  return series;
};

var plot_flot_series = function(flot_series, minTime, maxTime) {
  let ONE_DAY_IN_MS = 1000*60*60*24;
  try {
    return window.plot = $.plot($("#flot_container"), flot_series, {
      xaxis: {
        min: minTime,
        max: maxTime,
        mode: "time",
        timeformat: "%d %b %y",
        tickLength: 0,
        zoomRange: [ONE_DAY_IN_MS, maxTime - minTime],
        panRange: [minTime, maxTime],
        position: "top"
      },
      yaxis: {
        transform(v) { return -v; }, // flip y axis so morning is at the top
        inverseTransform(v) { return -v; },
        min: 0,
        max: 24,
        tickLength: 0,
        ticks: [0, 3, 6, 9, 12, 15, 18, 21, 24 ],
        tickFormatter(val, axis) {
          if (val === 0) { return "12am";
          } else if (val < 12) { return `${val}am`;
          } else if (val === 12) { return "12pm";
          } else { return `${val - 12}pm`; }
        },
        zoomRange: false,
        panRange: false
      },
      points: {
        radius: 1,
        show: true
      },
      grid: {
        clickable: true,
        hoverable: true,
        autoHighlight: false
      },
      zoom: {
        interactive: true
      },
      pan: {
        interactive: true
      }
    }
    );
  } catch (error) {
    return console.log(error);
  }
};

let flotScrobbleGraphView = new FlotScrobbleGraphView;

let redraw_on_response_number = 1;

appModel.on("change:user", () => redraw_on_response_number = 1);

fetchModel.on("newPageFetched", function() {
  if (fetchModel.numPagesFetched() === redraw_on_response_number) {
    // Redrawing is slow as hell, and O(n^2) if we draw it n times.
    // So only draw it log2(n) times, for O(nlogn) load times.  Do
    // this by only drawing on response 1, 2, 4, 8, 16... etc until
    // the final response.
    redraw_on_response_number *= 2;
    return flotScrobbleGraphView.render();
  }
});

fetchModel.on("change:isFetching", (model, isFetching) =>
  // Force a redraw when the last response comes through.
  flotScrobbleGraphView.render()
);

appModel.on("change:filterTerm", (model, oldFilterTerm) => flotScrobbleGraphView.render());
