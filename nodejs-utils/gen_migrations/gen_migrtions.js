const convert = require('xml-js');
const fs = require('fs');
const xml = fs.readFileSync(__dirname + '/dev-local-flyway-schema-comparison.html', 'utf8');

const result = JSON.parse(convert.xml2json(xml, {compact: true, spaces: 4}));
// console.log(result)
// tr [level 3] -> table name
let trs = []
const tables = []

// eliminate rows without tds
for (let tr of result.html.body.table.tr) {
  if(tr.td && tr.td.length > 0 && ['Table','Column', 'Data type'].includes(tr.td[0]._text) && tr.td[1]._text !== 'N/A' && tr.td[2]._text !== 'N/A' )
    trs.push(tr)
}
fs.writeFileSync(__dirname + '/schema-trs.json', JSON.stringify(trs, null, 4));

let i = 0
try {
  while (i < trs.length) {
    while (i < trs.length && trs[i].td[0]._text !== 'Table') {
      i++
    }
    if (i < trs.length) {
      const table = {name: trs[i].td[1]._text, columns: []}
      i++
      while (i < trs.length && trs[i].td[0]._text === 'Column') {
        const column = trs[i]
        const types = trs[i + 1].td
        if (types[0]._text == 'Data type') {
          table.columns.push({name: column.td[1]._text, sourceType: types[1]._text, requiredType: types[2]._text})
          i += 2
        } else {
          i++
        }
      }
      tables.push(table)
    }
  }
} catch (err) {
  console.log('*****************', JSON.stringify(trs[i]), null, 4)
  throw err
}
fs.writeFileSync(__dirname + '/schema-tables.json', JSON.stringify(tables));

console.log('BEGIN;\n')

for (let table of tables) {
  if(table.columns?.length > 0) {
    console.log(`--------- START ${table.name} ------------`)
    for (let column of table.columns) {
      if (column.sourceType !== column.requiredType) {
        let requiredType = (['serial4', 'bigserial'].includes(column.requiredType.toLowerCase())) ? 'integer' : column.requiredType;
        requiredType = column.requiredType === 'uuid' ? `uuid USING ${column.name}::uuid` : requiredType;
        console.log(`\n-- reverting column ${column.name} from ${column.sourceType} -> ${requiredType}`)
        console.log(`alter table if exists ${table.name} alter column ${column.name} set data type ${requiredType};`)
      }
    }
    console.log(`\n--------- END ${table.name} ------------\n\n`)
  }

}

console.log('END;\n')



