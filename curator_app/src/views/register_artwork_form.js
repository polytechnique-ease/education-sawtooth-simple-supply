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
const _ = require('lodash')
const L = require('leaflet')

const api = require('../services/api')
const parsing = require('../services/parsing')
const forms = require('../components/forms')
const layout = require('../components/layout')

const recordSubmitter = state => e => {
  e.preventDefault()

  const recordKeys = ['device', 'seq', 'ts', 'ddata', 'dsize', 'dhash', 'record_id']
  const record = _.pick(state, recordKeys)
//   record.latitude = parsing.toInt(record.latitude)
//   record.longitude = parsing.toInt(record.longitude)

  api.post('records', record)
    .then(() => m.route.set('/artworks'))
    .catch(api.alertError)
}

const RegisterArtworkForm = {
  view (vnode) {
    const setter = forms.stateSetter(vnode.state)
    return m('.register-form', [
      m('form', { onsubmit: recordSubmitter(vnode.state) },
      m('legend', 'Add Sensor Data'),
      layout.row([
        forms.group('Record ID', forms.field(setter('record_id'), {
          type: 'string',
          step: 'any',
        })),
        forms.group('Device', forms.field(setter('device'), {
          type: 'string',
          step: 'any',
        })),
        forms.group('Seq', forms.field(setter('seq'), {
          type: 'string',
          step: 'any',
        }))
      ]),
      layout.row([
        forms.group('TS', forms.field(setter('ts'), {
          type: 'string',
          step: 'any',
        })),
        forms.group('Ddata', forms.field(setter('ddata'), {
          type: 'string',
          step: 'any',
        }))
      ]),
      layout.row([
        forms.group('Dsize', forms.field(setter('dsize'), {
          type: 'string',
          step: 'any',
        })),
        forms.group('Dhash', forms.field(setter('dhash'), {
          type: 'string',
          step: 'any',
        }))
      ]),
      m('.form-group',
        m('.row.justify-content-end.align-items-end',
          m('col-2',
            m('button.btn.btn-primary',
              'Add Sensor Data')))))
    ])
  }
}

module.exports = RegisterArtworkForm
