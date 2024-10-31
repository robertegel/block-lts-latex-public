#import "@preview/cetz:0.2.2": draw, canvas, plot, coordinate
#import "@preview/suiji:0.3.0": shuffle, gen-rng
#import "@preview/statastic:0.1.0": arrayAvg
#import "@preview/oxifmt:0.2.1": strfmt
#import draw: *

#let make_axes(params) = {
  // axes
  plot.plot(
    size: (params.fig_width, params.fig_height),
    x-tick-step: none,
    y-tick-step: none,
    x-ticks: range(calc.ceil(params.fig_width)),
    axis-style: "left",
    x-min: - params.axis_xShift_scaler * params.xShift,
    x-max: params.fig_width - params.axis_xShift_scaler * params.xShift,
    x-label: [$ b $],
    y-label: [$ t $],
    {
      plot.add(style: params.axes_style, domain: (-2, -1), x=>x)
    },
    name: "axes",
  )
  // content((rel: (0, -0.2), to: "axes.south"), [Space / Block])
  // content((rel: (-0.3, 0), to: "axes.west"), [Time], angle: 90deg)
}

#let loop_no_scale(rectname, scale_back_i, params) = {
  scale_back_i = (scale_back_i + 1) * 0.1

  circle((
    rel: (params.label_xShift * params.dx - scale_back_i, 0),
    to: strfmt("{}.north-west", rectname),
  ), name: "node", radius: 0.0)

  bezier(
    (rel: (0.025, 0.0), update: false),
    (rel: (-0.025, 0.0), update: false),
    (rel: (0.1, 0.2), update: false),
    (rel: (-0.1, 0.2), update: false),
    // (rel: (-0.1, 0.2), update: false),
    stroke: params.scale_back_arrow_stroke,
    mark: (end: "straight"),
  )
}

#let scale_back_arrow(rectname, x_pos, y_pos, scale_back_i, full_compute_xShift, params) = {
  // scale_back_i = (1) * 0.1
  scale_back_i = (scale_back_i + 1) * params.scale_back_arrow_dist

  line(
    (
      rel: (params.label_xShift * params.dx - scale_back_i + full_compute_xShift, 0),
      to: strfmt("{}.north-west", rectname),
    ),
    ((x: x_pos + params.label_xShift * params.dx - scale_back_i + full_compute_xShift, y: y_pos)),
    stroke: params.scale_back_arrow_stroke,
    mark: (end: "straight"),
  )
}

#let make_block(b, params, dt_base: none) = {
  let rectname
  let dt

  if b == 0 {
    dt = (params.dt_0,) * params.nSteps_0
  } else {
    if dt_base == none {
      dt_base = (1.2, 0.7, 0.8, 1.0, 1.1, 1.2, 0.6, 1.1, 1.3)
    }
    if dt_base.len() * arrayAvg(dt_base) < params.nSteps_0 / params.dt_0 {
      dt_base = dt_base * int(params.nSteps_0 / arrayAvg(dt_base))
    }
    dt = ()
    if params.shuffle {
      let tmp_rng = gen-rng(b)
      (tmp_rng, dt) = shuffle(tmp_rng, dt_base)
    } else {
      dt = dt_base
    }
  }

  // reset rel coordinates
  let x_pos = b - 1 + params.xShift + params.axis_xShift_scaler / 2
  let t_n_start = 0
  let t_n_end
  let n = 0

  while t_n_start < params.dt_0 * params.nSteps_0 {
    t_n_end = t_n_start + dt.at(n)
    rectname = strfmt("rect{},{}", n, b)

    // rect with open south/bottom side
    group(
      {
        line(
          ((x_pos, t_n_start)),
          (rel: (0, dt.at(n))),
          (rel: (params.dx, 0)),
          (rel: (0, -dt.at(n))),
        )
      }, 
      stroke: params.rect_stroke,
      name: rectname,
    )

    // full compute arrow
    let full_compute_xShift = params.every_second_full_compute_xShift
    if calc.rem(n, 2) == 0 or b == 0 or not params.full_compute_overlap {
      full_compute_xShift = 0
    }
    // flux arrow
    line(
      (
        rel: (params.label_xShift * params.dx + full_compute_xShift, 0),
        to: rectname + ".south-west",
      ),
      (rel: (0, dt.at(n))),
      name: "flux",
      mark: params.arrow_mark,
      stroke: params.flux_arrow_stroke,
    )
    // arrow start mark
    line(
      (rel: (-0.025, 0), to: "flux.start"),
      (rel: (0.05, 0)),
      stroke: params.flux_arrow_stroke,
    )
    content(
      // (name: flux_name, anchor: -10pt),
      (name: "flux", anchor: 50%),
      [$Delta q_(#n,#b)$],
      anchor: "west",
      padding: 0.05,
    )

    // scale back arrows
    if b != 0 {
      let lower = calc.ceil(t_n_start * 2)
      let upper = calc.floor(t_n_end * 2)
      let scale_back_i = 0

      for t_n in range(lower, upper + 1, step: 1) {
        let y_pos = t_n / 2

        if y_pos == t_n_start or y_pos > params.dt_0 * params.nSteps_0 {
          continue
        }

        if y_pos == t_n_end and params.make_loops {
          loop_no_scale(rectname, scale_back_i, params)
        } else if y_pos != t_n_start and y_pos != t_n_end {
          scale_back_arrow(rectname, x_pos, y_pos, scale_back_i, 
          // full_compute_xShift,
          0,
          params)
        }
        scale_back_i += 1
      }
    }

    if params.full_compute_overlap {
      t_n_start += calc.floor(dt.at(n) / params.dt_0) * params.dt_0
    } else {
      t_n_start += dt.at(n)
    }
    n += 1
  }
}
