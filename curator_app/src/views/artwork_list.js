/**
 * Copyright 2018 Intel Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ----------------------------------------------------------------------------
 */

'use strict'

const m = require('mithril')
const sortBy = require('lodash/sortBy')
const Table = require('../components/tables.js')
const api = require('../services/api')

const ArtworkList = {
  oninit (vnode) {
    vnode.state.records = []
    vnode.state.recordsFinal = []
    api.get('records').then((records) => {
        vnode.state.records = sortBy(records, 'record_id')
        var rec = JSON.parse(JSON.stringify(vnode.state.records))
        for(int i = 0; i < rec.length; i++){
          console.log(rec[i].locations)
          vnode.state.recordsFinal.push({record_id: rec[i].record_id, data: rec[i].locations[0])
        }
      })
  },

  view (vnode) {
    return [
      m('.record-list',
        m(Table, {
          headers: [
            'ID', 'Device', 'Dsize', 'Ddata', 'TS', 'Seq', 'Dhash'
          ],
          rows: vnode.state.recordsFinal
            .map((record) => [
              record.record_id,
              record.data.device,
              record.data.dsize,
              record.data.ddata,
              record.data.ts,
              record.data.seq,
              record.data.dhash
            ]),
          noRowsText: 'No records found'
        })
      )
    ]
  }
}

module.exports = ArtworkList
