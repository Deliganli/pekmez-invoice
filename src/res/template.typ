#let invoice(
  data
) = {
  set page(paper: "a4", margin: (x: 20%, y: 20%, top: 20%, bottom: 20%))

  // Typst can't format numbers yet, so we use this from here:
  // https://github.com/typst/typst/issues/180#issuecomment-1484069775
  let format_currency(number) = {
    let precision = 2
    let s = str(calc.round(number, digits: precision))
    let after_dot = s.find(regex("\..*"))
    if after_dot == none {
      s = s + "."
      after_dot = "."
    }
    for i in range(precision - after_dot.len() + 1){
      s = s + "0"
    }
    s
  }

  let format_percentage(number) = {
    let precision = 2
    let s = str(calc.round(number, digits: precision))
    let after_dot = s.find(regex("\..*"))
    if after_dot != none {
      for i in range(precision - after_dot.len() + 1){
        s = s + "0"
      }
    }
    s
  }

  set text(number-type: "old-style")

  if data.at("author", default: none) != none {
    smallcaps[
      #if data.author.at("name", default: none) != none [ *#data.author.name* •]
      #if data.author.at("street", default: none) != none [ #data.author.street •]
      #if data.author.at("zip", default: none) != none [ #data.author.zip ]
      #if data.author.at("city", default: none) != none [ #data.author.city ]
      #if data.author.at("country", default: none) != none [ #data.author.country ]
    ]
  }

  v(1em)

  [
    #set par(leading: 0.40em)
    #set text(size: 1.2em)
    #if data.at("recipient", default: none) != none [
      #if data.recipient.at("name", default: none) != none [ #data.recipient.name \ ]
      #if data.recipient.at("street", default: none) != none [ #data.recipient.street \ ]
      #if data.recipient.at("zip", default: none) != none [ #data.recipient.zip ]
      #if data.recipient.at("city", default: none) != none [ #data.recipient.city ]
      #if data.recipient.at("country", default: none) != none [ #data.recipient.country ]
    ]
  ]

  v(4em)

  grid(columns: (1fr, 1fr), align: bottom, heading[
    #data.labels.invoice \##data.number
  ],
  [
    #set align(right)

    #if data.at("author", default: none) != none {
      if data.author.at("city", default: none) != none [#data.author.city, ]
    }
    *#data.date*
  ])

  let items = data.at("items", default: ())
  let total = items
    .map((item) => decimal(item.price))
    .sum(default: 0)

  let items = items
    .enumerate()
    .map(
      ((id, item)) => (
        [#str(id + 1).],
        [#item.desc],
        [#format_currency(decimal(item.price))#data.labels.currency],
      ),
    )
    .flatten()

  [
    #let tax = decimal(
      if data.at("tax", default: none) == none { 0 }
      else { data.at("tax", default: 0) }
    )
    #set text(number-type: "lining")
    #table(
      stroke: none,
      columns: (auto, 10fr, auto),
      align: ((column, row) => if column == 1 { left } else { right }),
      table.hline(stroke: (thickness: 0.5pt, dash: "dotted")),
      [*#data.labels.pos*], [*#data.labels.description*], [*#data.labels.price*],
      table.hline(),
      ..items,
      table.hline(),
      [],
      [
        #set align(end)
        #data.labels.subtotal:
      ],
      [#format_currency({(decimal(1) - tax) * total})#data.labels.currency],
      table.hline(start: 2),
      ..if tax != 0 {(
        [],
        [
          #set text(number-type: "old-style")
          #set align(end)
          #format_percentage(tax * 100)% #data.labels.tax:
        ],
        [#format_currency(tax * total)#data.labels.currency],
        table.hline(start: 2),
        [],
      )} else {([], [], [], [])},
      [
        #set align(end)
        *#data.labels.total:*
      ],
      [*#format_currency(total)#data.labels.currency*],
      table.hline(start: 2),
    )
  ]

  v(2em)

  [
    #set text(size: 0.8em)
    #data.notes
  ]

  if data.at("payment", default: none) != none {
    let payment_lines = data.payment
      .map((line) => (line.label, [:], line.value))
      .flatten()

    if payment_lines.at(0, default: none) != none {
      set text(number-type: "lining")
      box(
        inset: 10pt,
        radius: 2pt,
        stroke: 0.3pt,
        width: 100%,
        fill: cmyk(5%, 0%, 0%, 5%),
        {
          grid(
            align: left,
            columns: 3,
            gutter: 9pt,
            ..payment_lines
          )
        }
      )
  }
}

  [
    #set text(size: 0.8em)
    #set text(number-type: "lining")

    #if data.at("author", default: none) != none {
      smallcaps[
        #if data.author.at("tax_nr", default: none) != none [
          #data.labels.tax_number: #data.author.tax_nr
        ]
      ]
    }

    #v(0.5em)
    #data.labels.closing_statement
    #v(1em)

    #if data.at("author", default: none) != none {
      if data.author.at("name", default: none) != none {
        data.author.name
      }
    }
  ]
}
