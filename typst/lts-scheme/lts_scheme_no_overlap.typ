#import "../lib/lts_scheme.typ": *

#let latex_textwidth_factor = 0.8
#let margin = 2mm

#set page(width: auto, height: auto, margin: margin)
#set text(font: "New Computer Modern", size: 10pt)
#show math.equation: set text(font: "New Computer Modern Math")
#show raw: set text(font: "New Computer Modern Mono")

#let params = (
  xShift: 0.5,
  axis_xShift_scaler: 1.25,
  label_xShift: 0.5,
  every_second_full_compute_xShift: 0.05,
  fig_width: 4.2,
  fig_height: 5.5,
  // latex KOMA script textwidth -> resulting fig_width
  latex_fig_width: 157.49817mm * latex_textwidth_factor - margin,
  // latex_fig_width: 100mm,
  dx: 1,
  nSteps_0: 10,
  dt_0: 0.5,
  make_loops: false,
  shuffle: false,
  full_compute_overlap: false,
  //
  // style
  //
  rect_stroke: (paint: black, thickness: 1pt),
  timestep_stroke: (thickness: 0.5pt, dash: "densely-dotted"),
  scale_back_arrow_stroke: (thickness: 0.7pt, dash: "densely-dashed"),
  flux_arrow_stroke: (thickness: 0.7pt),
  arrow_mark: (end: "straight"),
  axes_style: (stroke: black, fill: rgb(0, 0, 200, 75)),
)

// main
#canvas(
  length: 2.5cm,
  {
    let _scale = params.latex_fig_width / ((params.fig_width + 1.1) * 2.5cm)
    scale(_scale)

    make_axes(params)

    // dotted lines for timesteps
    for n in range(params.nSteps_0 + 1){
      line(
        (0, params.dt_0 * n),
        (rel: (params.fig_width, 0)),
        stroke: params.timestep_stroke,
        name: strfmt("t{}", n),
      )
      if n == params.nSteps_0 {
        content(
          (0, params.dt_0 * n),
          [$t_"end"=t_(#n)$],
          anchor: "east",
          padding: 0.05,
          name: "label_t_end",
        )
      } else {
        content((0, params.dt_0 * n), [$t_(#n)$], anchor: "east", padding: 0.05)
      }
    }

    make_block(0, params)
    make_block(1, params, dt_base: (0.75, 0.8, 0.9, 1.0, 0.95, 1.2))
    make_block(2, params, dt_base: (2.4, 1.9, 1.1, 0.6,))
    make_block(3, params, dt_base: (0.9, 1.1, 1.4, 1.3))
  },
)
